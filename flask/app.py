
import os
from datetime import datetime, timedelta

from dotenv import load_dotenv
from flask import Flask, jsonify, request, session
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash

load_dotenv()

from database import get_connection

app = Flask(__name__)
app.secret_key = os.getenv('FLASK_SECRET_KEY', 'bubblecookies-local-dev-session-key-change-before-deploy')

CORS(app, supports_credentials=True, origins=[
    'http://localhost:4200',
    'http://127.0.0.1:4200'
])


# ============================================================
# CONEXION A MYSQL
# ============================================================

def rows(sql, args=()):
    con = get_connection()
    try:
        with con.cursor() as cur:
            cur.execute(sql, args)
            return cur.fetchall()
    finally:
        con.close()


def execute(sql, args=()):
    con = get_connection()
    try:
        with con.cursor() as cur:
            cur.execute(sql, args)
            result = cur.lastrowid
        con.commit()
        return result
    except:
        con.rollback()
        raise
    finally:
        con.close()


def fail(e):
    return jsonify({'estado': 'error', 'mensaje': str(e)}), 500


# ============================================================
# PERMISOS POR ROL
# ============================================================

@app.before_request
def role_access_control():
    path = request.path

    if not path.startswith('/api/') or request.method == 'OPTIONS':
        return None

    if (path in ['/api/auth/admin', '/api/auth/cliente', '/api/auth/registro-cliente', '/api/auth/logout', '/api/test-db']
        or (path == '/api/productos' and request.method == 'GET')
        or path.startswith('/api/carrito/')
        or (path == '/api/pedidos' and request.method == 'POST')):
        return None

    user = session.get('bubble_user')

    if not user:
        return jsonify({
            'mensaje': 'Sesión requerida. Inicia sesión nuevamente.'
        }), 401

    role = user.get('rol')

    if role in ('superadmin', 'administrador'):
        return None

    if role == 'cliente' and path == '/api/mis-pedidos' and request.method == 'GET':
        return None

    allowed_cook = (
        '/api/ingredientes',
        '/api/recetas',
        '/api/producciones',
        '/api/inventario-productos',
        '/api/dashboard'
    )

    allowed_marketing = (
        '/api/marketing',
        '/api/campanias',
        '/api/metricas-marketing',
        '/api/productos'
    )

    allowed = (
        allowed_cook if role == 'cocinero'
        else allowed_marketing if role == 'marketing'
        else ()
    )

    if any(path.startswith(prefix) for prefix in allowed):
        if (role == 'marketing'
            and path.startswith('/api/productos')
            and request.method != 'GET'):
            return jsonify({
                'mensaje': 'El perfil de marketing solo puede consultar el catálogo.'
            }), 403

        return None

    return jsonify({
        'mensaje': 'Tu perfil no tiene permisos para este módulo.'
    }), 403


# ============================================================
# CUENTAS DE USUARIO
# ============================================================

def ensure_role_accounts():
    """Migra el ENUM de roles y crea cuentas iniciales de cocina y marketing."""
    con = get_connection()

    try:
        with con.cursor() as c:
            c.execute("SHOW COLUMNS FROM administradores LIKE 'rol'")
            col = c.fetchone()

            if col and 'cocinero' not in str(col.get('Type', '')):
                c.execute(
                    "ALTER TABLE administradores MODIFY rol "
                    "ENUM('superadmin','administrador','cocinero','marketing') "
                    "NOT NULL DEFAULT 'administrador'"
                )

            defaults = [
                ('Cocinero BubbleCookies', 'cocina@bubblecookies.com',
                 'Cocina2026!', 'cocinero'),
                ('Marketing BubbleCookies', 'marketing@bubblecookies.com',
                 'Marketing2026!', 'marketing')
            ]

            for nombre, correo, password, rol in defaults:
                c.execute(
                    'SELECT id_administrador FROM administradores WHERE correo=%s',
                    (correo,)
                )

                if not c.fetchone():
                    c.execute(
                        'INSERT INTO administradores(nombre,correo,password_hash,rol) '
                        'VALUES(%s,%s,%s,%s)',
                        (nombre, correo, generate_password_hash(password), rol)
                    )

        con.commit()

    except Exception:
        con.rollback()
        raise

    finally:
        con.close()


# ============================================================
# RUTAS GENERALES
# ============================================================

@app.get('/')
def home():
    return jsonify({
        'proyecto': 'BubbleCookies',
        'estado': 'Servidor funcionando'
    })


@app.get('/api/test-db')
def test_db():
    try:
        return jsonify({
            'estado': 'success',
            'mensaje': 'Conexion MySQL exitosa',
            'base_datos': rows('SELECT DATABASE() AS base_datos')[0]['base_datos']
        })
    except Exception as e:
        return fail(e)


# ============================================================
# PRODUCTOS
# ============================================================

@app.get('/api/productos')
def productos():
    try:
        data = rows("""
            SELECT p.*,
                   COALESCE(i.existencia,0) existencia,
                   COALESCE(i.minimo,0) minimo,
                   COALESCE(i.unidades_vendidas_historicas,0) unidades_vendidas_historicas,
                   COALESCE(r.unidades_por_lote,12) unidades_por_lote
            FROM productos p
            LEFT JOIN inventario_productos i USING(id_producto)
            LEFT JOIN (
                SELECT id_producto, MAX(unidades_por_lote) unidades_por_lote
                FROM recetas
                WHERE activa=1
                GROUP BY id_producto
            ) r USING(id_producto)
            WHERE p.activo=1
            ORDER BY p.id_producto
        """)

        return jsonify({
            'estado': 'success',
            'total': len(data),
            'productos': data
        })

    except Exception as e:
        return fail(e)


# ============================================================
# DASHBOARD GENERAL
# ============================================================

@app.get('/api/dashboard')
def dashboard():
    try:
        ventas = rows("""
            SELECT COALESCE(SUM(total), 0) ventas,
                   COUNT(*) pedidos
            FROM pedidos
            WHERE estado <> 'cancelado'
        """)[0]

        productos = rows("""
            SELECT COUNT(*) productos
            FROM productos
            WHERE activo = 1
        """)[0]

        stock = rows("""
            SELECT COALESCE(SUM(existencia), 0) stock
            FROM inventario_productos
        """)[0]

        produccion = rows("""
            SELECT COALESCE(SUM(unidades_producidas), 0) producidos
            FROM producciones
            WHERE estado = 'completada'
        """)[0]

        registros = rows("""
            SELECT DATE_FORMAT(fecha_pedido, '%%Y-%%m-%%d') periodo,
                   COALESCE(SUM(total), 0) ventas,
                   COUNT(*) pedidos
            FROM pedidos
            WHERE estado <> 'cancelado'
              AND fecha_pedido >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
            GROUP BY DATE_FORMAT(fecha_pedido, '%%Y-%%m-%%d')
            ORDER BY periodo
        """)

        registros_por_dia = {
            item['periodo']: item for item in registros
        }

        ventas_semanales = []
        dias_espanol = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']
        hoy = datetime.now().date()

        for i in range(6, -1, -1):
            fecha = hoy - timedelta(days=i)
            fecha_texto = fecha.strftime('%Y-%m-%d')
            item = registros_por_dia.get(fecha_texto, {})

            ventas_semanales.append({
                'periodo': fecha_texto,
                'dia': dias_espanol[fecha.weekday()],
                'ventas': float(item.get('ventas') or 0),
                'pedidos': int(item.get('pedidos') or 0)
            })

        productos_vendidos = rows("""
            SELECT dp.nombre_producto nombre,
                   SUM(dp.cantidad) cantidad,
                   MAX(pr.imagen) imagen,
                   MAX(pr.color_hex) color
            FROM detalle_pedidos dp
            INNER JOIN pedidos p
                ON dp.id_pedido = p.id_pedido
            LEFT JOIN productos pr
                ON dp.id_producto = pr.id_producto
            WHERE p.estado <> 'cancelado'
              AND p.fecha_pedido >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
            GROUP BY dp.nombre_producto
            ORDER BY cantidad DESC
            LIMIT 5
        """)

        inventario_bajo = rows("""
            SELECT nombre, cantidad, unidad, stock_minimo
            FROM ingredientes
            WHERE activo = 1
            ORDER BY
                CASE
                    WHEN stock_minimo > 0
                    THEN cantidad / stock_minimo
                    ELSE cantidad
                END ASC
            LIMIT 6
        """)

        pedidos_estado = rows("""
            SELECT estado, COUNT(*) cantidad
            FROM pedidos
            GROUP BY estado
        """)

        pedidos = rows("""
            SELECT codigo_pedido,
                   nombre_cliente,
                   fecha_pedido,
                   total,
                   estado
            FROM pedidos
            ORDER BY fecha_pedido DESC
            LIMIT 8
        """)

        return jsonify({
            'stats': {
                **ventas,
                **productos,
                **stock,
                **produccion
            },
            'ventas_semanales': ventas_semanales,
            'productos_vendidos': productos_vendidos,
            'inventario_bajo': inventario_bajo,
            'pedidos_estado': pedidos_estado,
            'pedidos': pedidos
        })

    except Exception as e:
        import traceback
        traceback.print_exc()
        return fail(e)


# ============================================================
# MATERIA PRIMA
# ============================================================

@app.get('/api/ingredientes')
def ingredientes():
    try:
        return jsonify(rows(
            'SELECT * FROM ingredientes WHERE activo=1 ORDER BY nombre'
        ))
    except Exception as e:
        return fail(e)


@app.post('/api/ingredientes')
def ingrediente_add():
    try:
        d = request.get_json()

        i = execute(
            'INSERT INTO ingredientes(nombre,cantidad,unidad,costo_unitario,stock_minimo) '
            'VALUES(%s,%s,%s,%s,%s)',
            (
                d['nombre'],
                d.get('cantidad', 0),
                d['unidad'],
                d.get('costo_unitario', 0),
                d.get('stock_minimo', 0)
            )
        )

        return jsonify({'id': i, 'mensaje': 'Ingrediente registrado'})

    except Exception as e:
        return fail(e)


@app.put('/api/ingredientes/<int:i>')
def ingrediente_edit(i):
    try:
        d = request.get_json()

        execute(
            'UPDATE ingredientes SET nombre=%s,cantidad=%s,unidad=%s,'
            'costo_unitario=%s,stock_minimo=%s WHERE id_ingrediente=%s',
            (
                d['nombre'],
                d['cantidad'],
                d['unidad'],
                d['costo_unitario'],
                d.get('stock_minimo', 0),
                i
            )
        )

        return jsonify({'mensaje': 'Ingrediente actualizado'})

    except Exception as e:
        return fail(e)


# ============================================================
# RECETAS
# ============================================================

@app.get('/api/recetas')
def recetas():
    try:
        data = rows(
            'SELECT r.*,p.nombre producto FROM recetas r '
            'JOIN productos p USING(id_producto) '
            'WHERE r.activa=1 ORDER BY r.id_receta'
        )

        for item in data:
            item['ingredientes'] = rows(
                'SELECT id_ingrediente,cantidad,unidad FROM detalle_recetas '
                'WHERE id_receta=%s',
                (item['id_receta'],)
            )

        return jsonify(data)

    except Exception as e:
        return fail(e)


# ============================================================
# PRODUCCION
# ============================================================

@app.post('/api/producciones')
def produccion_add():
    con = None

    try:
        d = request.get_json(silent=True) or {}

        pid = int(d.get('id_producto', 0))
        lots = int(d.get('cantidad_lotes', 0))

        if pid <= 0 or lots <= 0:
            return jsonify({
                'mensaje': 'Selecciona un producto y una cantidad válida de lotes.'
            }), 400

        con = get_connection()

        with con.cursor() as c:

            # Buscar receta activa
            c.execute(
                'SELECT id_receta, unidades_por_lote '
                'FROM recetas '
                'WHERE id_producto=%s AND activa=1 '
                'LIMIT 1',
                (pid,)
            )

            recipe = c.fetchone()

            if not recipe:
                return jsonify({
                    'mensaje': 'El producto no tiene una receta activa.'
                }), 400

            # Consultar ingredientes necesarios
            c.execute(
                'SELECT dr.id_ingrediente, dr.cantidad, dr.unidad, '
                'i.nombre, i.cantidad AS existencia, i.costo_unitario '
                'FROM detalle_recetas dr '
                'JOIN ingredientes i USING(id_ingrediente) '
                'WHERE dr.id_receta=%s FOR UPDATE',
                (recipe['id_receta'],)
            )

            needs = c.fetchall()

            if not needs:
                con.rollback()
                return jsonify({
                    'mensaje': 'La receta no tiene ingredientes registrados.'
                }), 400

            # Verificar existencias
            for n in needs:
                required = float(n['cantidad']) * lots

                if float(n['existencia']) < required:
                    con.rollback()
                    return jsonify({
                        'mensaje': (
                            f"Materia prima insuficiente: {n['nombre']}. "
                            f"Necesitas {required:g} {n['unidad']} "
                            f"y tienes {float(n['existencia']):g}."
                        )
                    }), 409

            units = int(recipe['unidades_por_lote']) * lots

            code = 'BC-LOT-' + datetime.now().strftime(
                '%y%m%d%H%M%S%f'
            )

            # Registrar producción
            c.execute(
                'INSERT INTO producciones('
                'codigo_lote, id_producto, id_receta, '
                'cantidad_lotes, unidades_producidas, observaciones) '
                'VALUES(%s,%s,%s,%s,%s,%s)',
                (
                    code,
                    pid,
                    recipe['id_receta'],
                    lots,
                    units,
                    d.get('observaciones')
                )
            )

            production_id = c.lastrowid

            # Descontar materia prima
            for n in needs:
                required = round(
                    float(n['cantidad']) * lots, 3
                )

                old = float(n['existencia'])
                new = round(old - required, 3)

                c.execute(
                    'UPDATE ingredientes '
                    'SET cantidad=%s '
                    'WHERE id_ingrediente=%s',
                    (new, n['id_ingrediente'])
                )

                # Registrar consumo
                c.execute(
                    'INSERT INTO detalle_consumo_produccion('
                    'id_produccion, id_ingrediente, '
                    'cantidad_consumida, unidad, costo_unitario) '
                    'VALUES(%s,%s,%s,%s,%s)',
                    (
                        production_id,
                        n['id_ingrediente'],
                        required,
                        n['unidad'],
                        n['costo_unitario']
                    )
                )

                # Movimiento de materia prima
                c.execute(
                    'INSERT INTO movimientos_materia_prima('
                    'id_ingrediente, tipo, cantidad, '
                    'existencia_anterior, existencia_nueva, '
                    'referencia, observaciones) '
                    "VALUES(%s,'salida_produccion',%s,%s,%s,%s,%s)",
                    (
                        n['id_ingrediente'],
                        required,
                        old,
                        new,
                        code,
                        d.get('observaciones')
                    )
                )

            # Consultar inventario terminado
            c.execute(
                'SELECT existencia '
                'FROM inventario_productos '
                'WHERE id_producto=%s FOR UPDATE',
                (pid,)
            )

            stock = c.fetchone()

            old_stock = int(stock['existencia']) if stock else 0
            new_stock = old_stock + units

            if stock:
                c.execute(
                    'UPDATE inventario_productos '
                    'SET existencia=%s '
                    'WHERE id_producto=%s',
                    (new_stock, pid)
                )
            else:
                c.execute(
                    'INSERT INTO inventario_productos('
                    'id_producto, existencia, minimo) '
                    'VALUES(%s,%s,0)',
                    (pid, units)
                )

            # Registrar entrada al inventario
            c.execute(
                'INSERT INTO movimientos_producto_terminado('
                'id_producto, tipo, cantidad, '
                'existencia_anterior, existencia_nueva, '
                'referencia, observaciones) '
                "VALUES(%s,'entrada_produccion',%s,%s,%s,%s,%s)",
                (
                    pid,
                    units,
                    old_stock,
                    new_stock,
                    code,
                    d.get('observaciones')
                )
            )

        # Guardar todos los cambios
        con.commit()

        return jsonify({
            'estado': 'success',
            'mensaje': f'Producción registrada: {units} galletas.',
            'id_produccion': production_id,
            'codigo_lote': code
        }), 201

    except Exception as e:
        import traceback
        traceback.print_exc()

        if con:
            con.rollback()

        return jsonify({
            'estado': 'error',
            'mensaje': f'Error al registrar producción: {str(e)}'
        }), 500

    finally:
        if con:
            con.close()



# ============================================================
# HISTORIAL DE PRODUCCION
# ============================================================

@app.get('/api/producciones')
def obtener_producciones():
    try:
        data = rows("""
            SELECT
                pr.*,
                p.nombre AS producto
            FROM producciones pr
            LEFT JOIN productos p
                ON pr.id_producto = p.id_producto
            ORDER BY pr.fecha_produccion DESC
            LIMIT 100
        """)

        return jsonify(data)

    except Exception as e:
        return fail(e)


# ============================================================
# CLIENTES
# ============================================================

@app.get('/api/clientes')
def clientes():
    try:
        return jsonify(rows(
            'SELECT id_cliente,nombre,apellidos,correo,telefono,ciudad,creado_en '
            'FROM clientes WHERE activo=1 ORDER BY creado_en DESC'
        ))
    except Exception as e:
        return fail(e)


# ============================================================
# PEDIDOS
# ============================================================

@app.get('/api/pedidos')
def pedidos():
    try:
        return jsonify(rows(
            'SELECT p.*, '
            "(SELECT GROUP_CONCAT(CONCAT(dp.nombre_producto, ' × ', dp.cantidad) "
            "ORDER BY dp.id_detalle_pedido SEPARATOR ', ') "
            'FROM detalle_pedidos dp WHERE dp.id_pedido=p.id_pedido) AS resumen_productos '
            'FROM pedidos p ORDER BY p.fecha_pedido DESC'
        ))
    except Exception as e:
        return fail(e)


@app.get('/api/mis-pedidos')
def mis_pedidos():
    try:
        user = session.get('bubble_user') or {}
        if user.get('rol') != 'cliente' or not user.get('id_cliente'):
            return jsonify({'mensaje': 'Inicia sesión como cliente para consultar tus pedidos.'}), 401
        pedidos_cliente = rows(
            'SELECT id_pedido,codigo_pedido,fecha_pedido,subtotal,costo_envio,descuento,total,estado,mensaje_regalo '
            'FROM pedidos WHERE id_cliente=%s OR correo_cliente=%s ORDER BY fecha_pedido DESC',
            (user['id_cliente'], user.get('correo'))
        )
        for pedido in pedidos_cliente:
            pedido['productos'] = rows(
                'SELECT nombre_producto,cantidad,precio_unitario,subtotal '
                'FROM detalle_pedidos WHERE id_pedido=%s ORDER BY id_detalle_pedido',
                (pedido['id_pedido'],)
            )
        return jsonify({'pedidos': pedidos_cliente})
    except Exception as e:
        return fail(e)


@app.get('/api/pedidos/<int:i>/detalle')
def pedido_detalle(i):
    try:
        return jsonify(rows(
            'SELECT nombre_producto,cantidad,precio_unitario,subtotal '
            'FROM detalle_pedidos WHERE id_pedido=%s ORDER BY id_detalle_pedido',
            (i,)
        ))
    except Exception as e:
        return fail(e)


@app.put('/api/pedidos/<int:i>')
def pedido_status(i):
    try:
        data = request.get_json() or {}
        estado = data.get('estado')
        estados_validos = {'pendiente', 'en_preparacion', 'completado'}

        if estado == 'cancelado':
            return jsonify({
                'mensaje': 'Utiliza la acción Cancelar para devolver el inventario correctamente.'
            }), 409
        if estado not in estados_validos:
            return jsonify({'mensaje': 'El estado del pedido no es válido.'}), 400
        existente = rows('SELECT id_pedido FROM pedidos WHERE id_pedido=%s', (i,))
        if not existente:
            return jsonify({'mensaje': 'El pedido no existe.'}), 404

        execute(
            'UPDATE pedidos SET estado=%s WHERE id_pedido=%s',
            (estado, i)
        )
        return jsonify({'mensaje': 'Estado actualizado'})

    except Exception as e:
        return fail(e)


# ============================================================
# PROVEEDORES
# ============================================================

@app.get('/api/proveedores')
def proveedores():
    try:
        return jsonify(rows(
            'SELECT * FROM proveedores WHERE activo=1 ORDER BY nombre'
        ))
    except Exception as e:
        return fail(e)


@app.post('/api/proveedores')
def proveedor_add():
    try:
        d = request.get_json()

        i = execute(
            'INSERT INTO proveedores(nombre,contacto,telefono,correo) '
            'VALUES(%s,%s,%s,%s)',
            (
                d['nombre'],
                d.get('contacto'),
                d.get('telefono'),
                d.get('correo')
            )
        )

        return jsonify({'id': i})

    except Exception as e:
        return fail(e)


# ============================================================
# COMPRAS
# ============================================================

@app.get('/api/compras')
def compras():
    try:
        return jsonify(rows(
            'SELECT c.*,p.nombre proveedor FROM compras c '
            'JOIN proveedores p USING(id_proveedor) '
            'ORDER BY fecha_compra DESC'
        ))
    except Exception as e:
        return fail(e)


# ============================================================
# MARKETING Y GRAFICAS
# ============================================================

@app.get('/api/marketing')
def marketing():
    try:
        stats = rows("""
            SELECT
                COALESCE(SUM(alcance), 0) alcance,
                COALESCE(SUM(impresiones), 0) impresiones,
                COALESCE(SUM(interacciones), 0) interacciones,
                COALESCE(SUM(conversiones), 0) conversiones
            FROM metricas_marketing
        """)[0]

        campaigns = rows("""
            SELECT c.*, COALESCE(AVG(m.roas), 0) roas
            FROM campanias_marketing c
            LEFT JOIN metricas_marketing m USING(id_campania)
            GROUP BY c.id_campania
            ORDER BY c.creado_en DESC
        """)

        sabores = rows("""
            SELECT dp.nombre_producto nombre,
                   SUM(dp.cantidad) cantidad
            FROM detalle_pedidos dp
            JOIN pedidos p USING(id_pedido)
            WHERE p.estado <> 'cancelado'
            GROUP BY dp.nombre_producto
            ORDER BY cantidad DESC
            LIMIT 5
        """)

        canales = rows("""
            SELECT c.canal,
                   COALESCE(AVG(m.roas), 0) roas
            FROM campanias_marketing c
            LEFT JOIN metricas_marketing m USING(id_campania)
            GROUP BY c.canal
            ORDER BY roas DESC
        """)

        return jsonify({
            'stats': stats,
            'campanias': campaigns,
            'sabores': sabores,
            'canales': canales
        })

    except Exception as e:
        return fail(e)


# ============================================================
# CARRITO DE COMPRAS
# ============================================================

@app.get('/api/carrito/<token>')
def carrito_get(token):
    try:
        con = get_connection()

        with con.cursor() as c:
            c.execute(
                "SELECT id_carrito FROM carritos "
                "WHERE token_sesion=%s AND estado='activo' LIMIT 1",
                (token,)
            )
            cart = c.fetchone()

            if not cart:
                c.execute(
                    "INSERT INTO carritos(token_sesion,estado) "
                    "VALUES(%s,'activo')",
                    (token,)
                )
                cart = {'id_carrito': c.lastrowid}
                con.commit()

            c.execute(
                'SELECT p.id_producto,p.nombre,p.precio,p.imagen,'
                'dc.cantidad,(p.precio*dc.cantidad) subtotal '
                'FROM detalle_carrito dc JOIN productos p USING(id_producto) '
                'WHERE dc.id_carrito=%s',
                (cart['id_carrito'],)
            )
            items = c.fetchall()

        return jsonify({
            'items': items,
            'cantidad_total': sum(int(x['cantidad']) for x in items),
            'total': round(sum(float(x['subtotal']) for x in items), 2)
        })

    except Exception as e:
        return fail(e)

    finally:
        if 'con' in locals():
            con.close()


@app.post('/api/carrito/<token>')
def carrito_add(token):
    try:
        d = request.get_json()
        pid = int(d['id_producto'])
        con = get_connection()

        with con.cursor() as c:
            c.execute(
                "SELECT id_carrito FROM carritos "
                "WHERE token_sesion=%s AND estado='activo'",
                (token,)
            )
            cart = c.fetchone()

            if not cart:
                c.execute(
                    "INSERT INTO carritos(token_sesion,estado) "
                    "VALUES(%s,'activo')",
                    (token,)
                )
                cart = {'id_carrito': c.lastrowid}

            c.execute(
                'SELECT precio FROM productos WHERE id_producto=%s AND activo=1',
                (pid,)
            )
            p = c.fetchone()

            if not p:
                return jsonify({'mensaje': 'Producto no encontrado'}), 404

            c.execute(
                'SELECT existencia FROM inventario_productos '
                'WHERE id_producto=%s FOR UPDATE',
                (pid,)
            )
            stock = c.fetchone()
            stock_available = int(stock['existencia']) if stock else 0

            c.execute(
                'SELECT cantidad FROM detalle_carrito '
                'WHERE id_carrito=%s AND id_producto=%s',
                (cart['id_carrito'], pid)
            )
            cart_item = c.fetchone()
            cart_quantity = int(cart_item['cantidad']) if cart_item else 0

            if stock_available < cart_quantity + 1:
                con.rollback()
                return jsonify({
                    'mensaje': (
                        'No hay stock suficiente para agregar este producto. '
                        f'Existencias disponibles: {stock_available}.'
                    ),
                    'stock_disponible': stock_available,
                    'cantidad_en_carrito': cart_quantity
                }), 409

            c.execute(
                'INSERT INTO detalle_carrito('
                'id_carrito,id_producto,cantidad,precio_unitario) '
                'VALUES(%s,%s,1,%s) '
                'ON DUPLICATE KEY UPDATE cantidad=cantidad+1',
                (cart['id_carrito'], pid, p['precio'])
            )

        con.commit()
        return jsonify({'mensaje': 'Producto agregado al carrito'})

    except Exception as e:
        return fail(e)

    finally:
        if 'con' in locals():
            con.close()


@app.patch('/api/carrito/<token>')
def carrito_update(token):
    try:
        d = request.get_json()
        pid = int(d['id_producto'])
        qty = max(0, int(d.get('cantidad', 1)))

        if qty == 0:
            execute(
                'DELETE dc FROM detalle_carrito dc '
                'JOIN carritos c USING(id_carrito) '
                'WHERE c.token_sesion=%s AND dc.id_producto=%s',
                (token, pid)
            )
        else:
            execute(
                'UPDATE detalle_carrito dc '
                'JOIN carritos c USING(id_carrito) '
                'SET dc.cantidad=%s '
                'WHERE c.token_sesion=%s AND dc.id_producto=%s',
                (qty, token, pid)
            )

        return jsonify({'mensaje': 'Carrito actualizado'})

    except Exception as e:
        return fail(e)


@app.delete('/api/carrito/<token>')
def carrito_clear(token):
    try:
        execute(
            'DELETE dc FROM detalle_carrito dc '
            'JOIN carritos c USING(id_carrito) '
            'WHERE c.token_sesion=%s',
            (token,)
        )
        return jsonify({'mensaje': 'Carrito vaciado'})

    except Exception as e:
        return fail(e)


# ============================================================
# CREACION DE PEDIDOS
# ============================================================

@app.post('/api/pedidos')
def pedido_create():
    con = None

    try:
        d = request.get_json()
        token = 'bubblecookies-session'
        con = get_connection()

        with con.cursor() as c:
            c.execute(
                "SELECT id_carrito FROM carritos "
                "WHERE token_sesion=%s AND estado='activo'",
                (token,)
            )
            cart = c.fetchone()

            if not cart:
                return jsonify({'mensaje': 'Tu carrito está vacío.'}), 400

            c.execute(
                'SELECT dc.id_producto,dc.cantidad,dc.precio_unitario,p.nombre '
                'FROM detalle_carrito dc '
                'JOIN productos p USING(id_producto) '
                'WHERE dc.id_carrito=%s',
                (cart['id_carrito'],)
            )
            items = c.fetchall()

            if not items:
                return jsonify({'mensaje': 'Tu carrito está vacío.'}), 400

            subtotal = sum(
                float(x['cantidad'] * x['precio_unitario']) for x in items
            )
            code = 'BC-' + datetime.now().strftime('%y%m%d%H%M%S')

            cliente_sesion = session.get('bubble_user') or {}
            id_cliente = cliente_sesion.get('id_cliente') if cliente_sesion.get('rol') == 'cliente' else None
            nombre_cliente = d.get('nombre_cliente') or cliente_sesion.get('nombre') or 'Cliente'
            correo_cliente = d.get('correo_cliente') or cliente_sesion.get('correo')

            c.execute(
                "INSERT INTO pedidos("
                "codigo_pedido,id_cliente,nombre_cliente,correo_cliente,telefono_cliente,"
                "direccion_entrega,subtotal,total,estado,mensaje_regalo,es_demo) "
                "VALUES(%s,%s,%s,%s,%s,%s,%s,%s,'pendiente',%s,0)",
                (
                    code,
                    id_cliente,
                    nombre_cliente,
                    correo_cliente,
                    d.get('telefono_cliente'),
                    d.get('direccion_entrega'),
                    subtotal,
                    subtotal,
                    d.get('mensaje_regalo')
                )
            )
            oid = c.lastrowid

            for x in items:
                c.execute(
                    'SELECT existencia FROM inventario_productos '
                    'WHERE id_producto=%s FOR UPDATE',
                    (x['id_producto'],)
                )
                stock = c.fetchone()

                if stock and int(stock['existencia']) < int(x['cantidad']):
                    con.rollback()
                    return jsonify({
                        'mensaje': f"Existencias insuficientes para {x['nombre']}."
                    }), 409

                c.execute(
                    'INSERT INTO detalle_pedidos('
                    'id_pedido,id_producto,nombre_producto,cantidad,'
                    'precio_unitario,subtotal) '
                    'VALUES(%s,%s,%s,%s,%s,%s)',
                    (
                        oid,
                        x['id_producto'],
                        x['nombre'],
                        x['cantidad'],
                        x['precio_unitario'],
                        x['cantidad'] * x['precio_unitario']
                    )
                )

                if stock:
                    before = int(stock['existencia'])
                    after = before - int(x['cantidad'])

                    c.execute(
                        'UPDATE inventario_productos '
                        'SET existencia=%s,'
                        'unidades_vendidas_historicas=unidades_vendidas_historicas+%s '
                        'WHERE id_producto=%s',
                        (after, x['cantidad'], x['id_producto'])
                    )

                    c.execute(
                        "INSERT INTO movimientos_producto_terminado("
                        "id_producto,tipo,cantidad,existencia_anterior,"
                        "existencia_nueva,referencia) "
                        "VALUES(%s,'salida_venta',%s,%s,%s,%s)",
                        (
                            x['id_producto'],
                            x['cantidad'],
                            before,
                            after,
                            code
                        )
                    )

            c.execute(
                'DELETE FROM detalle_carrito WHERE id_carrito=%s',
                (cart['id_carrito'],)
            )

        con.commit()
        return jsonify({
            'mensaje': f'Pedido {code} registrado correctamente.',
            'codigo_pedido': code
        })

    except Exception as e:
        if con:
            con.rollback()
        return fail(e)

    finally:
        if con:
            con.close()


# ============================================================
# INICIO Y CIERRE DE SESION
# ============================================================

@app.post('/api/auth/admin')
def auth_admin():
    try:
        d = request.get_json() or {}
        correo = (d.get('correo') or '').strip().lower()
        password = d.get('password') or ''

        ensure_role_accounts()

        usuarios = rows(
            'SELECT id_administrador,nombre,correo,password_hash,rol '
            'FROM administradores WHERE correo=%s AND activo=1',
            (correo,)
        )

        if (not usuarios
            and correo == 'admin@bubblecookies.com'
            and password == 'Bubble2026!'):

            execute(
                'INSERT INTO administradores(nombre,correo,password_hash,rol) '
                'VALUES(%s,%s,%s,%s)',
                (
                    'Administrador BubbleCookies',
                    correo,
                    generate_password_hash(password),
                    'superadmin'
                )
            )

            usuarios = rows(
                'SELECT id_administrador,nombre,correo,password_hash,rol '
                'FROM administradores WHERE correo=%s AND activo=1',
                (correo,)
            )

        if (not usuarios
            or not usuarios[0]['password_hash']
            or not check_password_hash(usuarios[0]['password_hash'], password)):
            return jsonify({
                'mensaje': 'Credenciales incorrectas o administrador no registrado.'
            }), 401

        execute(
            'UPDATE administradores SET ultimo_acceso=NOW() '
            'WHERE id_administrador=%s',
            (usuarios[0]['id_administrador'],)
        )

        user = {
            k: v for k, v in usuarios[0].items()
            if k != 'password_hash'
        }

        session['bubble_user'] = user

        return jsonify({
            'estado': 'success',
            'usuario': user
        })

    except Exception as e:
        return fail(e)


@app.post('/api/auth/logout')
def auth_logout():
    session.clear()
    return jsonify({'mensaje': 'Sesión cerrada.'})


@app.post('/api/auth/cliente')
def auth_cliente():
    try:
        d = request.get_json() or {}
        correo = (d.get('correo') or '').strip().lower()
        password = d.get('password') or ''
        if not correo or not password:
            return jsonify({'mensaje': 'Escribe tu correo y contraseña.'}), 400
        u = rows(
            'SELECT id_cliente,nombre,apellidos,correo,telefono,password_hash '
            'FROM clientes WHERE correo=%s AND activo=1',
            (correo,)
        )
        if not u or not u[0].get('password_hash') or not check_password_hash(u[0]['password_hash'], password):
            return jsonify({'mensaje': 'Correo o contraseña incorrectos.'}), 401
        user = {
            'id_cliente': u[0]['id_cliente'], 'nombre': u[0]['nombre'],
            'apellidos': u[0].get('apellidos'), 'correo': u[0]['correo'],
            'telefono': u[0].get('telefono'), 'rol': 'cliente'
        }
        session['bubble_user'] = user
        return jsonify({'estado': 'success', 'usuario': user})
    except Exception as e:
        return fail(e)


@app.post('/api/auth/registro-cliente')
def registro_cliente():
    try:
        d = request.get_json() or {}
        nombre_completo = ' '.join((d.get('nombre') or '').strip().split())
        correo = (d.get('correo') or '').strip().lower()
        password = d.get('password') or ''
        telefono = (d.get('telefono') or '').strip() or None
        if len(nombre_completo) < 3:
            return jsonify({'mensaje': 'Escribe tu nombre completo.'}), 400
        if '@' not in correo or '.' not in correo.split('@')[-1]:
            return jsonify({'mensaje': 'Escribe un correo electrónico válido.'}), 400
        if len(password) < 8:
            return jsonify({'mensaje': 'La contraseña debe tener al menos 8 caracteres.'}), 400
        partes = nombre_completo.split(' ', 1)
        nombre = partes[0]
        apellidos = partes[1] if len(partes) > 1 else None
        existentes = rows('SELECT id_cliente,password_hash FROM clientes WHERE correo=%s', (correo,))
        if existentes and existentes[0].get('password_hash'):
            return jsonify({'mensaje': 'Ya existe una cuenta con ese correo. Inicia sesión.'}), 409
        if existentes:
            nuevo_id = existentes[0]['id_cliente']
            execute(
                'UPDATE clientes SET nombre=%s,apellidos=%s,telefono=%s,password_hash=%s,activo=1 WHERE id_cliente=%s',
                (nombre, apellidos, telefono, generate_password_hash(password), nuevo_id)
            )
        else:
            nuevo_id = execute(
                'INSERT INTO clientes(nombre,apellidos,correo,telefono,password_hash,activo) VALUES(%s,%s,%s,%s,%s,1)',
                (nombre, apellidos, correo, telefono, generate_password_hash(password))
            )
        user = {'id_cliente': nuevo_id, 'nombre': nombre, 'apellidos': apellidos, 'correo': correo, 'telefono': telefono, 'rol': 'cliente'}
        session['bubble_user'] = user
        return jsonify({'estado': 'success', 'mensaje': '¡Tu cuenta fue creada! Bienvenido a BubbleCookies.', 'usuario': user}), 201
    except Exception as e:
        return fail(e)


# ============================================================
# ELIMINAR INGREDIENTES
# ============================================================

@app.delete('/api/ingredientes/<int:i>')
def ingrediente_delete(i):
    con = None

    try:
        con = get_connection()

        with con.cursor() as c:
            c.execute(
                'SELECT id_ingrediente FROM ingredientes WHERE id_ingrediente=%s',
                (i,)
            )

            if not c.fetchone():
                return jsonify({
                    'mensaje': 'El ingrediente ya no existe.'
                }), 404

            c.execute(
                'SELECT COUNT(*) n FROM detalle_recetas WHERE id_ingrediente=%s',
                (i,)
            )
            en_receta = c.fetchone()['n']

            c.execute(
                'SELECT COUNT(*) n FROM movimientos_materia_prima '
                'WHERE id_ingrediente=%s',
                (i,)
            )
            historial = c.fetchone()['n']

            c.execute(
                'SELECT COUNT(*) n FROM detalle_consumo_produccion '
                'WHERE id_ingrediente=%s',
                (i,)
            )
            historial += c.fetchone()['n']

            if en_receta or historial:
                c.execute(
                    'UPDATE ingredientes SET activo=0 WHERE id_ingrediente=%s',
                    (i,)
                )
                mensaje = 'Ingrediente desactivado: tiene recetas o movimientos históricos relacionados.'
                modo = 'desactivado'
            else:
                c.execute(
                    'DELETE FROM ingredientes WHERE id_ingrediente=%s',
                    (i,)
                )
                mensaje = 'Ingrediente eliminado físicamente de MySQL.'
                modo = 'eliminado'

        con.commit()
        return jsonify({'mensaje': mensaje, 'modo': modo})

    except Exception as e:
        if con:
            con.rollback()
        return fail(e)

    finally:
        if con:
            con.close()


# ============================================================
# ADMINISTRAR PRODUCTOS
# ============================================================

@app.post('/api/productos')
def producto_add():
    try:
        d = request.get_json() or {}

        i = execute(
            'INSERT INTO productos(nombre,descripcion,precio,imagen,color_hex,etiqueta) '
            'VALUES(%s,%s,%s,%s,%s,%s)',
            (
                d['nombre'],
                d.get('descripcion'),
                d.get('precio', 0),
                d.get('imagen'),
                d.get('color_hex'),
                d.get('etiqueta')
            )
        )

        return jsonify({
            'id': i,
            'mensaje': 'Producto registrado correctamente.'
        })

    except Exception as e:
        return fail(e)


@app.put('/api/productos/<int:i>')
def producto_edit(i):
    try:
        d = request.get_json() or {}

        execute(
            'UPDATE productos SET nombre=%s,descripcion=%s,precio=%s,'
            'imagen=%s,color_hex=%s,etiqueta=%s WHERE id_producto=%s',
            (
                d['nombre'],
                d.get('descripcion'),
                d.get('precio', 0),
                d.get('imagen'),
                d.get('color_hex'),
                d.get('etiqueta'),
                i
            )
        )

        return jsonify({'mensaje': 'Producto actualizado correctamente.'})

    except Exception as e:
        return fail(e)


@app.delete('/api/productos/<int:i>')
def producto_delete(i):
    con = None

    try:
        con = get_connection()

        with con.cursor() as c:
            c.execute(
                'SELECT id_producto FROM productos WHERE id_producto=%s',
                (i,)
            )

            if not c.fetchone():
                return jsonify({'mensaje': 'El producto no existe.'}), 404

            refs = 0

            for tabla, campo in [
                ('inventario_productos', 'id_producto'),
                ('recetas', 'id_producto'),
                ('detalle_carrito', 'id_producto'),
                ('detalle_pedidos', 'id_producto'),
                ('producciones', 'id_producto'),
                ('movimientos_producto_terminado', 'id_producto')
            ]:
                c.execute(
                    f'SELECT COUNT(*) n FROM {tabla} WHERE {campo}=%s',
                    (i,)
                )
                refs += int(c.fetchone()['n'])

            if refs:
                c.execute(
                    'UPDATE productos SET activo=0 WHERE id_producto=%s',
                    (i,)
                )
                modo = 'desactivado'
                mensaje = 'Producto desactivado: conserva inventario o historial relacionado.'
            else:
                c.execute(
                    'DELETE FROM productos WHERE id_producto=%s',
                    (i,)
                )
                modo = 'eliminado'
                mensaje = 'Producto eliminado físicamente de MySQL.'

        con.commit()
        return jsonify({'mensaje': mensaje, 'modo': modo})

    except Exception as e:
        if con:
            con.rollback()
        return fail(e)

    finally:
        if con:
            con.close()


# ============================================================
# ADMINISTRAR CLIENTES
# ============================================================

@app.post('/api/clientes')
def cliente_add():
    try:
        d = request.get_json() or {}

        i = execute(
            'INSERT INTO clientes(nombre,apellidos,correo,telefono,ciudad) '
            'VALUES(%s,%s,%s,%s,%s)',
            (
                d['nombre'],
                d.get('apellidos'),
                d.get('correo') or None,
                d.get('telefono'),
                d.get('ciudad')
            )
        )

        return jsonify({
            'id': i,
            'mensaje': 'Cliente registrado correctamente.'
        })

    except Exception as e:
        return fail(e)


@app.put('/api/clientes/<int:i>')
def cliente_edit(i):
    try:
        d = request.get_json() or {}

        execute(
            'UPDATE clientes SET nombre=%s,apellidos=%s,correo=%s,'
            'telefono=%s,ciudad=%s WHERE id_cliente=%s',
            (
                d['nombre'],
                d.get('apellidos'),
                d.get('correo') or None,
                d.get('telefono'),
                d.get('ciudad'),
                i
            )
        )

        return jsonify({'mensaje': 'Cliente actualizado correctamente.'})

    except Exception as e:
        return fail(e)


@app.delete('/api/clientes/<int:i>')
def cliente_delete(i):
    con = None

    try:
        con = get_connection()

        with con.cursor() as c:
            c.execute(
                'SELECT id_cliente FROM clientes WHERE id_cliente=%s',
                (i,)
            )

            if not c.fetchone():
                return jsonify({'mensaje': 'El cliente no existe.'}), 404

            c.execute(
                'SELECT COUNT(*) n FROM pedidos WHERE id_cliente=%s',
                (i,)
            )
            refs = c.fetchone()['n']

            c.execute(
                'SELECT COUNT(*) n FROM carritos WHERE id_cliente=%s',
                (i,)
            )
            refs += c.fetchone()['n']

            if refs:
                c.execute(
                    'UPDATE clientes SET activo=0 WHERE id_cliente=%s',
                    (i,)
                )
                modo = 'desactivado'
                mensaje = 'Cliente desactivado: se conserva por su historial de pedidos.'
            else:
                c.execute(
                    'DELETE FROM clientes WHERE id_cliente=%s',
                    (i,)
                )
                modo = 'eliminado'
                mensaje = 'Cliente eliminado físicamente de MySQL.'

        con.commit()
        return jsonify({'mensaje': mensaje, 'modo': modo})

    except Exception as e:
        if con:
            con.rollback()
        return fail(e)

    finally:
        if con:
            con.close()


# ============================================================
# ADMINISTRAR PROVEEDORES
# ============================================================

@app.put('/api/proveedores/<int:i>')
def proveedor_edit(i):
    try:
        d = request.get_json() or {}

        execute(
            'UPDATE proveedores SET nombre=%s,contacto=%s,telefono=%s,correo=%s '
            'WHERE id_proveedor=%s',
            (
                d['nombre'],
                d.get('contacto'),
                d.get('telefono'),
                d.get('correo'),
                i
            )
        )

        return jsonify({'mensaje': 'Proveedor actualizado correctamente.'})

    except Exception as e:
        return fail(e)


@app.delete('/api/proveedores/<int:i>')
def proveedor_delete(i):
    con = None

    try:
        con = get_connection()

        with con.cursor() as c:
            c.execute(
                'SELECT id_proveedor FROM proveedores WHERE id_proveedor=%s',
                (i,)
            )

            if not c.fetchone():
                return jsonify({'mensaje': 'El proveedor no existe.'}), 404

            c.execute(
                'SELECT COUNT(*) n FROM compras WHERE id_proveedor=%s',
                (i,)
            )
            refs = c.fetchone()['n']

            if refs:
                c.execute(
                    'UPDATE proveedores SET activo=0 WHERE id_proveedor=%s',
                    (i,)
                )
                modo = 'desactivado'
                mensaje = 'Proveedor desactivado: se conserva por su historial de compras.'
            else:
                c.execute(
                    'DELETE FROM proveedores WHERE id_proveedor=%s',
                    (i,)
                )
                modo = 'eliminado'
                mensaje = 'Proveedor eliminado físicamente de MySQL.'

        con.commit()
        return jsonify({'mensaje': mensaje, 'modo': modo})

    except Exception as e:
        if con:
            con.rollback()
        return fail(e)

    finally:
        if con:
            con.close()


# ============================================================
# CAMPANIAS DE MARKETING
# ============================================================

@app.post('/api/campanias')
def campania_add():
    try:
        d = request.get_json() or {}

        i = execute(
            'INSERT INTO campanias_marketing('
            'nombre,canal,fecha_inicio,fecha_fin,presupuesto,estado) '
            'VALUES(%s,%s,%s,%s,%s,%s)',
            (
                d['nombre'],
                d['canal'],
                d.get('fecha_inicio') or None,
                d.get('fecha_fin') or None,
                d.get('presupuesto', 0),
                d.get('estado', 'activa')
            )
        )

        return jsonify({'id': i, 'mensaje': 'Campaña registrada.'})

    except Exception as e:
        return fail(e)


@app.put('/api/campanias/<int:i>')
def campania_edit(i):
    try:
        d = request.get_json() or {}

        execute(
            'UPDATE campanias_marketing SET nombre=%s,canal=%s,'
            'fecha_inicio=%s,fecha_fin=%s,presupuesto=%s,estado=%s '
            'WHERE id_campania=%s',
            (
                d['nombre'],
                d['canal'],
                d.get('fecha_inicio') or None,
                d.get('fecha_fin') or None,
                d.get('presupuesto', 0),
                d.get('estado', 'activa'),
                i
            )
        )

        return jsonify({'mensaje': 'Campaña actualizada.'})

    except Exception as e:
        return fail(e)


@app.delete('/api/campanias/<int:i>')
def campania_delete(i):
    try:
        con = get_connection()

        try:
            with con.cursor() as c:
                c.execute(
                    'SELECT COUNT(*) n FROM metricas_marketing '
                    'WHERE id_campania=%s',
                    (i,)
                )
                n = c.fetchone()['n']

                if n:
                    c.execute(
                        "UPDATE campanias_marketing SET estado='finalizada' "
                        "WHERE id_campania=%s",
                        (i,)
                    )
                    mensaje = 'Campaña finalizada; se conservaron sus métricas históricas.'
                    modo = 'finalizada'
                else:
                    c.execute(
                        'DELETE FROM campanias_marketing WHERE id_campania=%s',
                        (i,)
                    )
                    mensaje = 'Campaña eliminada de MySQL.'
                    modo = 'eliminada'

            con.commit()
            return jsonify({'mensaje': mensaje, 'modo': modo})

        finally:
            con.close()

    except Exception as e:
        return fail(e)


# ============================================================
# ADMINISTRAR RECETAS
# ============================================================

@app.post('/api/recetas')
def receta_add():
    con = None

    try:
        d = request.get_json() or {}
        detalles = d.get('ingredientes') or []

        if not detalles:
            return jsonify({
                'mensaje': 'Agrega al menos un ingrediente a la receta.'
            }), 400

        con = get_connection()

        with con.cursor() as c:
            c.execute(
                'INSERT INTO recetas('
                'id_producto,nombre,unidades_por_lote,instrucciones) '
                'VALUES(%s,%s,%s,%s)',
                (
                    d['id_producto'],
                    d['nombre'],
                    d.get('unidades_por_lote', 12),
                    d.get('instrucciones')
                )
            )
            rid = c.lastrowid

            for ing in detalles:
                c.execute(
                    'INSERT INTO detalle_recetas('
                    'id_receta,id_ingrediente,cantidad,unidad) '
                    'VALUES(%s,%s,%s,%s)',
                    (
                        rid,
                        ing['id_ingrediente'],
                        ing['cantidad'],
                        ing['unidad']
                    )
                )

        con.commit()
        return jsonify({'mensaje': 'Receta creada.', 'id_receta': rid})

    except Exception as e:
        if con:
            con.rollback()
        return fail(e)

    finally:
        if con:
            con.close()


@app.put('/api/recetas/<int:i>')
def receta_edit(i):
    con = None

    try:
        d = request.get_json() or {}
        con = get_connection()

        with con.cursor() as c:
            c.execute(
                'UPDATE recetas SET nombre=%s,unidades_por_lote=%s,'
                'instrucciones=%s WHERE id_receta=%s',
                (
                    d['nombre'],
                    d.get('unidades_por_lote', 12),
                    d.get('instrucciones'),
                    i
                )
            )

            if 'ingredientes' in d:
                c.execute(
                    'DELETE FROM detalle_recetas WHERE id_receta=%s',
                    (i,)
                )

                for ing in d.get('ingredientes', []):
                    c.execute(
                        'INSERT INTO detalle_recetas('
                        'id_receta,id_ingrediente,cantidad,unidad) '
                        'VALUES(%s,%s,%s,%s)',
                        (
                            i,
                            ing['id_ingrediente'],
                            ing['cantidad'],
                            ing['unidad']
                        )
                    )

        con.commit()
        return jsonify({'mensaje': 'Receta actualizada.'})

    except Exception as e:
        if con:
            con.rollback()
        return fail(e)

    finally:
        if con:
            con.close()


@app.delete('/api/recetas/<int:i>')
def receta_delete(i):
    try:
        execute(
            'UPDATE recetas SET activa=0 WHERE id_receta=%s',
            (i,)
        )
        return jsonify({'mensaje': 'Receta desactivada.'})

    except Exception as e:
        return fail(e)


# ============================================================
# CANCELAR PRODUCCION
# ============================================================

@app.delete('/api/producciones/<int:i>')
def produccion_cancel(i):
    con = None

    try:
        con = get_connection()

        with con.cursor() as c:
            c.execute(
                'SELECT * FROM producciones WHERE id_produccion=%s FOR UPDATE',
                (i,)
            )
            pr = c.fetchone()

            if not pr:
                return jsonify({'mensaje': 'Producción no encontrada.'}), 404

            if pr['estado'] == 'cancelada':
                return jsonify({
                    'mensaje': 'La producción ya estaba cancelada.'
                }), 409

            c.execute(
                'SELECT id_ingrediente,cantidad_consumida,unidad,costo_unitario '
                'FROM detalle_consumo_produccion WHERE id_produccion=%s',
                (i,)
            )
            consumed = c.fetchall()

            c.execute(
                'SELECT existencia FROM inventario_productos '
                'WHERE id_producto=%s FOR UPDATE',
                (pr['id_producto'],)
            )
            inv = c.fetchone()

            if not inv or int(inv['existencia']) < int(pr['unidades_producidas']):
                return jsonify({
                    'mensaje': 'No se puede cancelar: parte del producto ya fue vendido o el stock cambió.'
                }), 409

            old = int(inv['existencia'])
            new = old - int(pr['unidades_producidas'])

            c.execute(
                'UPDATE inventario_productos SET existencia=%s '
                'WHERE id_producto=%s',
                (new, pr['id_producto'])
            )

            c.execute(
                "INSERT INTO movimientos_producto_terminado("
                "id_producto,tipo,cantidad,existencia_anterior,"
                "existencia_nueva,referencia,observaciones) "
                "VALUES(%s,'ajuste_salida',%s,%s,%s,%s,'Reversión de producción')",
                (
                    pr['id_producto'],
                    pr['unidades_producidas'],
                    old,
                    new,
                    pr['codigo_lote']
                )
            )

            for item in consumed:
                c.execute(
                    'SELECT cantidad FROM ingredientes '
                    'WHERE id_ingrediente=%s FOR UPDATE',
                    (item['id_ingrediente'],)
                )
                row = c.fetchone()

                if row:
                    before = float(row['cantidad'])
                    after = before + float(item['cantidad_consumida'])

                    c.execute(
                        'UPDATE ingredientes SET cantidad=%s '
                        'WHERE id_ingrediente=%s',
                        (after, item['id_ingrediente'])
                    )

                    c.execute(
                        "INSERT INTO movimientos_materia_prima("
                        "id_ingrediente,tipo,cantidad,existencia_anterior,"
                        "existencia_nueva,referencia,observaciones) "
                        "VALUES(%s,'ajuste_entrada',%s,%s,%s,%s,'Reversión de producción')",
                        (
                            item['id_ingrediente'],
                            item['cantidad_consumida'],
                            before,
                            after,
                            pr['codigo_lote']
                        )
                    )

            c.execute(
                "UPDATE producciones SET estado='cancelada' "
                "WHERE id_produccion=%s",
                (i,)
            )

        con.commit()
        return jsonify({
            'mensaje': 'Producción cancelada y existencias revertidas.'
        })

    except Exception as e:
        if con:
            con.rollback()
        return fail(e)

    finally:
        if con:
            con.close()


# ============================================================
# CANCELAR PEDIDOS
# ============================================================

@app.delete('/api/pedidos/<int:i>')
def pedido_cancel(i):
    con = None

    try:
        con = get_connection()

        with con.cursor() as c:
            c.execute(
                'SELECT * FROM pedidos WHERE id_pedido=%s FOR UPDATE',
                (i,)
            )
            order = c.fetchone()

            if not order:
                return jsonify({'mensaje': 'Pedido no encontrado.'}), 404

            if order['estado'] == 'cancelado':
                return jsonify({
                    'mensaje': 'El pedido ya está cancelado.'
                }), 409

            c.execute(
                'SELECT id_producto,cantidad FROM detalle_pedidos '
                'WHERE id_pedido=%s',
                (i,)
            )
            items = c.fetchall()

            for item in items:
                if item['id_producto']:
                    c.execute(
                        'SELECT existencia FROM inventario_productos '
                        'WHERE id_producto=%s FOR UPDATE',
                        (item['id_producto'],)
                    )
                    inv = c.fetchone()

                    if inv:
                        before = int(inv['existencia'])
                        after = before + int(item['cantidad'])

                        c.execute(
                            'UPDATE inventario_productos SET existencia=%s '
                            'WHERE id_producto=%s',
                            (after, item['id_producto'])
                        )

                        c.execute(
                            "INSERT INTO movimientos_producto_terminado("
                            "id_producto,tipo,cantidad,existencia_anterior,"
                            "existencia_nueva,referencia,observaciones) "
                            "VALUES(%s,'ajuste_entrada',%s,%s,%s,%s,"
                            "'Reversión de pedido cancelado')",
                            (
                                item['id_producto'],
                                item['cantidad'],
                                before,
                                after,
                                order['codigo_pedido']
                            )
                        )

            c.execute(
                "UPDATE pedidos SET estado='cancelado' WHERE id_pedido=%s",
                (i,)
            )

        con.commit()
        return jsonify({
            'mensaje': 'Pedido cancelado y existencias devueltas.'
        })

    except Exception as e:
        if con:
            con.rollback()
        return fail(e)

    finally:
        if con:
            con.close()


# ============================================================
# REGISTRAR Y CANCELAR COMPRAS
# ============================================================

@app.post('/api/compras')
def compra_add():
    con = None

    try:
        d = request.get_json() or {}
        detalles = d.get('detalles') or []

        if not detalles:
            return jsonify({
                'mensaje': 'Agrega al menos un ingrediente a la compra.'
            }), 400

        con = get_connection()

        with con.cursor() as c:
            total = sum(
                float(x['cantidad']) * float(x['costo_unitario'])
                for x in detalles
            )

            c.execute(
                "INSERT INTO compras(id_proveedor,total,estado,observaciones) "
                "VALUES(%s,%s,'recibida',%s)",
                (d['id_proveedor'], total, d.get('observaciones'))
            )
            cid = c.lastrowid

            for x in detalles:
                c.execute(
                    'SELECT cantidad FROM ingredientes '
                    'WHERE id_ingrediente=%s FOR UPDATE',
                    (x['id_ingrediente'],)
                )
                row = c.fetchone()

                if not row:
                    raise ValueError('Ingrediente inexistente')

                before = float(row['cantidad'])
                qty = float(x['cantidad'])
                after = before + qty
                cost = float(x['costo_unitario'])

                c.execute(
                    'UPDATE ingredientes SET cantidad=%s,costo_unitario=%s '
                    'WHERE id_ingrediente=%s',
                    (after, cost, x['id_ingrediente'])
                )

                c.execute(
                    'INSERT INTO detalle_compras('
                    'id_compra,id_ingrediente,cantidad,costo_unitario,subtotal) '
                    'VALUES(%s,%s,%s,%s,%s)',
                    (
                        cid,
                        x['id_ingrediente'],
                        qty,
                        cost,
                        qty * cost
                    )
                )

                c.execute(
                    "INSERT INTO movimientos_materia_prima("
                    "id_ingrediente,tipo,cantidad,existencia_anterior,"
                    "existencia_nueva,referencia,observaciones) "
                    "VALUES(%s,'entrada_compra',%s,%s,%s,%s,%s)",
                    (
                        x['id_ingrediente'],
                        qty,
                        before,
                        after,
                        str(cid),
                        d.get('observaciones')
                    )
                )

        con.commit()
        return jsonify({
            'mensaje': 'Compra registrada y materia prima actualizada.',
            'id_compra': cid
        })

    except Exception as e:
        if con:
            con.rollback()
        return fail(e)

    finally:
        if con:
            con.close()


@app.delete('/api/compras/<int:i>')
def compra_cancel(i):
    con = None

    try:
        con = get_connection()

        with con.cursor() as c:
            c.execute(
                'SELECT * FROM compras WHERE id_compra=%s FOR UPDATE',
                (i,)
            )
            buy = c.fetchone()

            if not buy:
                return jsonify({'mensaje': 'Compra no encontrada.'}), 404

            if buy['estado'] == 'cancelada':
                return jsonify({
                    'mensaje': 'La compra ya está cancelada.'
                }), 409

            c.execute(
                'SELECT id_ingrediente,cantidad FROM detalle_compras '
                'WHERE id_compra=%s',
                (i,)
            )
            items = c.fetchall()

            for x in items:
                c.execute(
                    'SELECT cantidad FROM ingredientes '
                    'WHERE id_ingrediente=%s FOR UPDATE',
                    (x['id_ingrediente'],)
                )
                row = c.fetchone()

                if not row or float(row['cantidad']) < float(x['cantidad']):
                    return jsonify({
                        'mensaje': 'No se puede cancelar: la materia prima comprada ya fue consumida.'
                    }), 409

                before = float(row['cantidad'])
                after = before - float(x['cantidad'])

                c.execute(
                    'UPDATE ingredientes SET cantidad=%s WHERE id_ingrediente=%s',
                    (after, x['id_ingrediente'])
                )

                c.execute(
                    "INSERT INTO movimientos_materia_prima("
                    "id_ingrediente,tipo,cantidad,existencia_anterior,"
                    "existencia_nueva,referencia,observaciones) "
                    "VALUES(%s,'ajuste_salida',%s,%s,%s,%s,"
                    "'Reversión de compra')",
                    (
                        x['id_ingrediente'],
                        x['cantidad'],
                        before,
                        after,
                        str(i)
                    )
                )

            c.execute(
                "UPDATE compras SET estado='cancelada' WHERE id_compra=%s",
                (i,)
            )

        con.commit()
        return jsonify({
            'mensaje': 'Compra cancelada y existencias revertidas.'
        })

    except Exception as e:
        if con:
            con.rollback()
        return fail(e)

    finally:
        if con:
            con.close()


# ============================================================
# METRICAS DE MARKETING
# ============================================================

@app.post('/api/metricas-marketing')
def metrica_add():
    try:
        d = request.get_json() or {}

        i = execute(
            'INSERT INTO metricas_marketing('
            'id_campania,fecha,alcance,impresiones,interacciones,clics,'
            'conversiones,inversion,ingresos_atribuidos,tasa_conversion,roas) '
            'VALUES(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',
            (
                d['id_campania'],
                d['fecha'],
                d.get('alcance', 0),
                d.get('impresiones', 0),
                d.get('interacciones', 0),
                d.get('clics', 0),
                d.get('conversiones', 0),
                d.get('inversion', 0),
                d.get('ingresos_atribuidos', 0),
                d.get('tasa_conversion', 0),
                d.get('roas', 0)
            )
        )

        return jsonify({'id': i, 'mensaje': 'Métrica registrada.'})

    except Exception as e:
        return fail(e)


# ============================================================
# INVENTARIO DE PRODUCTO TERMINADO
# ============================================================

@app.put('/api/inventario-productos/<int:i>')
def inventario_producto_update(i):
    con = None

    try:
        d = request.get_json() or {}
        nuevo = max(0, int(d.get('existencia', 0)))
        minimo = max(0, int(d.get('minimo', 0)))
        con = get_connection()

        with con.cursor() as c:
            c.execute(
                'SELECT existencia FROM inventario_productos '
                'WHERE id_producto=%s FOR UPDATE',
                (i,)
            )
            old = c.fetchone()

            if old:
                anterior = int(old['existencia'])

                c.execute(
                    'UPDATE inventario_productos '
                    'SET existencia=%s,minimo=%s WHERE id_producto=%s',
                    (nuevo, minimo, i)
                )
            else:
                anterior = 0

                c.execute(
                    'INSERT INTO inventario_productos(id_producto,existencia,minimo) '
                    'VALUES(%s,%s,%s)',
                    (i, nuevo, minimo)
                )

            delta = abs(nuevo - anterior)

            if delta:
                tipo = (
                    'ajuste_entrada' if nuevo > anterior
                    else 'ajuste_salida'
                )

                c.execute(
                    'INSERT INTO movimientos_producto_terminado('
                    'id_producto,tipo,cantidad,existencia_anterior,'
                    'existencia_nueva,observaciones) '
                    'VALUES(%s,%s,%s,%s,%s,%s)',
                    (
                        i,
                        tipo,
                        delta,
                        anterior,
                        nuevo,
                        d.get('observaciones', 'Ajuste manual desde inventario')
                    )
                )

        con.commit()
        return jsonify({
            'mensaje': 'Inventario actualizado y movimiento registrado.'
        })

    except Exception as e:
        if con:
            con.rollback()
        return fail(e)

    finally:
        if con:
            con.close()


@app.delete('/api/inventario-productos/<int:i>')
def inventario_producto_clear(i):
    con = None

    try:
        con = get_connection()

        with con.cursor() as c:
            c.execute(
                'SELECT existencia FROM inventario_productos '
                'WHERE id_producto=%s FOR UPDATE',
                (i,)
            )
            row = c.fetchone()

            if not row:
                return jsonify({
                    'mensaje': 'No existe un registro de inventario para este producto.'
                }), 404

            before = int(row['existencia'])

            c.execute(
                'UPDATE inventario_productos SET existencia=0 '
                'WHERE id_producto=%s',
                (i,)
            )

            if before:
                c.execute(
                    "INSERT INTO movimientos_producto_terminado("
                    "id_producto,tipo,cantidad,existencia_anterior,"
                    "existencia_nueva,observaciones) "
                    "VALUES(%s,'ajuste_salida',%s,%s,0,"
                    "'Retiro manual de inventario')",
                    (i, before, before)
                )

        con.commit()
        return jsonify({
            'mensaje': 'Existencias retiradas y movimiento guardado.'
        })

    except Exception as e:
        if con:
            con.rollback()
        return fail(e)

    finally:
        if con:
            con.close()


# ============================================================
# INICIAR FLASK
# ============================================================

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
