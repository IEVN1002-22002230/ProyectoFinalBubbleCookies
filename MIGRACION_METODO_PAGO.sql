-- Ejecutar una sola vez sobre la base bubblecookies_db existente.
ALTER TABLE pedidos ADD COLUMN metodo_pago VARCHAR(20) NOT NULL DEFAULT 'efectivo' AFTER mensaje_regalo;
