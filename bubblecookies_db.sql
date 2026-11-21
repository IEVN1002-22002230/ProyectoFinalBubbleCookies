-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Nov 21, 2026 at 01:35 AM
-- Server version: 8.4.3
-- PHP Version: 8.3.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bubblecookies_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `administradores`
--

CREATE TABLE `administradores` (
  `id_administrador` int UNSIGNED NOT NULL,
  `nombre` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correo` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rol` enum('superadmin','administrador','cocinero','marketing') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'administrador',
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `ultimo_acceso` datetime DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `administradores`
--

INSERT INTO `administradores` (`id_administrador`, `nombre`, `correo`, `password_hash`, `rol`, `activo`, `ultimo_acceso`, `creado_en`, `actualizado_en`) VALUES
(1, 'Cocinero BubbleCookies', 'cocina@bubblecookies.com', 'scrypt:32768:8:1$HxknqnwjYHOTp5JU$d78498cab6265bc22abd1f1c2943a7c4deffd82bc496b9dfe0bdbe459e75839ad1b845612684fae11375188d2c4c63a18989102b42f957ff0cf5400742ef2c2e', 'cocinero', 1, '2026-11-17 18:25:17', '2026-11-18 00:08:23', '2026-11-18 00:25:17'),
(2, 'Marketing BubbleCookies', 'marketing@bubblecookies.com', 'scrypt:32768:8:1$GkDhXOvVpYwYaEIp$da7c08926db530564d72517178cbc79a22c050ecfd822e936bc4028225f7542455a8474f435ed61d4e0be3309f264fc74a62de4465daf7968735e647a009bd06', 'marketing', 1, '2026-11-19 16:40:16', '2026-11-18 00:08:23', '2026-11-19 22:40:16'),
(3, 'Administrador BubbleCookies', 'admin@bubblecookies.com', 'scrypt:32768:8:1$Sd8QQjHMO8zNMTSP$7bcad4b642baf6214117856a8e8bbca2de7114c2ed5047aab52e212bb13f0bc9446b65f55c3f1dc07a340b723e944f63e6461e81dc13dadbb1725e19977102df', 'superadmin', 1, '2026-11-19 16:50:34', '2026-11-18 00:08:23', '2026-11-19 22:50:34');

-- --------------------------------------------------------

--
-- Table structure for table `campanias_marketing`
--

CREATE TABLE `campanias_marketing` (
  `id_campania` int UNSIGNED NOT NULL,
  `nombre` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `canal` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL,
  `presupuesto` decimal(12,2) NOT NULL DEFAULT '0.00',
  `estado` enum('planeada','activa','pausada','finalizada') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'activa',
  `es_demo` tinyint(1) NOT NULL DEFAULT '0',
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `campanias_marketing`
--

INSERT INTO `campanias_marketing` (`id_campania`, `nombre`, `canal`, `fecha_inicio`, `fecha_fin`, `presupuesto`, `estado`, `es_demo`, `creado_en`) VALUES
(1, 'Campaña Instagram - BubbleCookies', 'Instagram', '2025-06-01', '2025-06-30', 0.00, 'finalizada', 1, '2026-11-17 23:50:25'),
(2, 'Campaña TikTok - BubbleCookies', 'TikTok', '2025-06-01', '2025-06-30', 0.00, 'finalizada', 1, '2026-11-17 23:50:25'),
(3, 'Campaña Mercado Libre - BubbleCookies', 'Mercado Libre', '2025-06-01', '2025-06-30', 0.00, 'finalizada', 1, '2026-11-17 23:50:25'),
(4, 'Resumen general de campañas (demo)', 'General', '2025-06-01', '2025-06-30', 0.00, 'finalizada', 1, '2026-11-17 23:50:25');

-- --------------------------------------------------------

--
-- Table structure for table `carritos`
--

CREATE TABLE `carritos` (
  `id_carrito` int UNSIGNED NOT NULL,
  `id_cliente` int UNSIGNED DEFAULT NULL,
  `token_sesion` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` enum('activo','convertido','abandonado') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'activo',
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `carritos`
--

INSERT INTO `carritos` (`id_carrito`, `id_cliente`, `token_sesion`, `estado`, `creado_en`, `actualizado_en`) VALUES
(1, NULL, 'bubblecookies-session', 'activo', '2026-11-18 00:08:03', '2026-11-18 00:08:03');

-- --------------------------------------------------------

--
-- Table structure for table `clientes`
--

CREATE TABLE `clientes` (
  `id_cliente` int UNSIGNED NOT NULL,
  `nombre` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellidos` varchar(160) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correo` varchar(160) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `direccion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `colonia` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `codigo_postal` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ciudad` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `clientes`
--

INSERT INTO `clientes` (`id_cliente`, `nombre`, `apellidos`, `correo`, `telefono`, `password_hash`, `direccion`, `colonia`, `codigo_postal`, `ciudad`, `estado`, `activo`, `creado_en`, `actualizado_en`) VALUES
(1, 'María', 'García', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-11-17 23:50:25', '2026-11-17 23:50:25'),
(2, 'Carlos', 'Mendoza', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-11-17 23:50:25', '2026-11-17 23:50:25'),
(3, 'Ana', 'Martínez', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-11-17 23:50:25', '2026-11-17 23:50:25'),
(4, 'Luis', 'Hernández', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-11-17 23:50:25', '2026-11-17 23:50:25');

-- --------------------------------------------------------

--
-- Table structure for table `compras`
--

CREATE TABLE `compras` (
  `id_compra` int UNSIGNED NOT NULL,
  `id_proveedor` int UNSIGNED NOT NULL,
  `fecha_compra` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `estado` enum('registrada','recibida','cancelada') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'recibida',
  `observaciones` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `creada_por` int UNSIGNED DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ;

--
-- Dumping data for table `compras`
--

INSERT INTO `compras` (`id_compra`, `id_proveedor`, `fecha_compra`, `total`, `estado`, `observaciones`, `creada_por`, `creado_en`) VALUES
(1, 1, '2025-06-18 12:00:00', 600.00, 'cancelada', 'Compra histórica de demostración; inventario inicial ya refleja las existencias actuales.', NULL, '2026-11-17 23:50:25'),
(2, 2, '2025-06-17 12:00:00', 1450.00, 'recibida', 'Compra histórica de demostración; inventario inicial ya refleja las existencias actuales.', NULL, '2026-11-17 23:50:25'),
(3, 4, '2026-11-19 18:35:47', 2596.00, 'recibida', '', NULL, '2026-11-20 00:35:47'),
(4, 4, '2026-11-19 18:35:47', 2596.00, 'recibida', '', NULL, '2026-11-20 00:35:47');

-- --------------------------------------------------------

--
-- Table structure for table `detalle_carrito`
--

CREATE TABLE `detalle_carrito` (
  `id_detalle_carrito` int UNSIGNED NOT NULL,
  `id_carrito` int UNSIGNED NOT NULL,
  `id_producto` int UNSIGNED NOT NULL,
  `cantidad` int UNSIGNED NOT NULL DEFAULT '1',
  `precio_unitario` decimal(10,2) NOT NULL
) ;

--
-- Dumping data for table `detalle_carrito`
--

INSERT INTO `detalle_carrito` (`id_detalle_carrito`, `id_carrito`, `id_producto`, `cantidad`, `precio_unitario`) VALUES
(11, 1, 2, 5, 48.00),
(16, 1, 1, 2, 45.00),
(17, 1, 3, 1, 50.00);

-- --------------------------------------------------------

--
-- Table structure for table `detalle_compras`
--

CREATE TABLE `detalle_compras` (
  `id_detalle_compra` int UNSIGNED NOT NULL,
  `id_compra` int UNSIGNED NOT NULL,
  `id_ingrediente` int UNSIGNED NOT NULL,
  `cantidad` decimal(12,3) NOT NULL,
  `costo_unitario` decimal(12,2) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL
) ;

--
-- Dumping data for table `detalle_compras`
--

INSERT INTO `detalle_compras` (`id_detalle_compra`, `id_compra`, `id_ingrediente`, `cantidad`, `costo_unitario`, `subtotal`) VALUES
(1, 1, 1, 25.000, 24.00, 600.00),
(2, 2, 2, 10.000, 145.00, 1450.00),
(3, 3, 6, 44.000, 59.00, 2596.00),
(4, 4, 6, 44.000, 59.00, 2596.00);

-- --------------------------------------------------------

--
-- Table structure for table `detalle_consumo_produccion`
--

CREATE TABLE `detalle_consumo_produccion` (
  `id_consumo` int UNSIGNED NOT NULL,
  `id_produccion` int UNSIGNED NOT NULL,
  `id_ingrediente` int UNSIGNED NOT NULL,
  `cantidad_consumida` decimal(12,3) NOT NULL,
  `unidad` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `costo_unitario` decimal(12,2) NOT NULL DEFAULT '0.00'
) ;

--
-- Dumping data for table `detalle_consumo_produccion`
--

INSERT INTO `detalle_consumo_produccion` (`id_consumo`, `id_produccion`, `id_ingrediente`, `cantidad_consumida`, `unidad`, `costo_unitario`) VALUES
(67, 12, 1, 0.600, 'kg', 24.00),
(68, 12, 2, 0.300, 'kg', 145.00),
(69, 12, 3, 0.250, 'kg', 32.00),
(70, 12, 4, 0.250, 'kg', 220.00),
(71, 12, 5, 2.000, 'pza', 3.50),
(72, 12, 6, 0.010, 'L', 59.00);

-- --------------------------------------------------------

--
-- Table structure for table `detalle_pedidos`
--

CREATE TABLE `detalle_pedidos` (
  `id_detalle_pedido` int UNSIGNED NOT NULL,
  `id_pedido` int UNSIGNED NOT NULL,
  `id_producto` int UNSIGNED DEFAULT NULL,
  `nombre_producto` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cantidad` int UNSIGNED NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL
) ;

--
-- Dumping data for table `detalle_pedidos`
--

INSERT INTO `detalle_pedidos` (`id_detalle_pedido`, `id_pedido`, `id_producto`, `nombre_producto`, `cantidad`, `precio_unitario`, `subtotal`) VALUES
(1, 1028, 1, 'Bubble Choco', 6, 45.00, 270.00),
(2, 1027, NULL, 'Caja mixta (composición no especificada en el proyecto original)', 12, 45.00, 540.00),
(3, 1026, 2, 'Double Fresa', 4, 48.00, 192.00),
(4, 1025, 3, 'Red Velvet', 6, 50.00, 300.00);

-- --------------------------------------------------------

--
-- Table structure for table `detalle_recetas`
--

CREATE TABLE `detalle_recetas` (
  `id_detalle_receta` int UNSIGNED NOT NULL,
  `id_receta` int UNSIGNED NOT NULL,
  `id_ingrediente` int UNSIGNED NOT NULL,
  `cantidad` decimal(12,3) NOT NULL,
  `unidad` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL
) ;

--
-- Dumping data for table `detalle_recetas`
--

INSERT INTO `detalle_recetas` (`id_detalle_receta`, `id_receta`, `id_ingrediente`, `cantidad`, `unidad`) VALUES
(1, 1, 1, 0.600, 'kg'),
(2, 1, 2, 0.300, 'kg'),
(3, 1, 3, 0.250, 'kg'),
(4, 1, 4, 0.250, 'kg'),
(5, 1, 5, 2.000, 'pza'),
(6, 1, 6, 0.010, 'L'),
(7, 2, 1, 0.600, 'kg'),
(8, 2, 2, 0.300, 'kg'),
(9, 2, 3, 0.250, 'kg'),
(10, 2, 7, 0.250, 'kg'),
(11, 2, 5, 2.000, 'pza'),
(12, 2, 6, 0.010, 'L'),
(13, 3, 1, 0.600, 'kg'),
(14, 3, 2, 0.300, 'kg'),
(15, 3, 3, 0.250, 'kg'),
(16, 3, 8, 0.250, 'kg'),
(17, 3, 5, 2.000, 'pza'),
(18, 3, 6, 0.010, 'L'),
(19, 4, 1, 0.600, 'kg'),
(20, 4, 2, 0.550, 'kg'),
(21, 4, 3, 0.250, 'kg'),
(22, 4, 5, 2.000, 'pza'),
(23, 4, 6, 0.010, 'L'),
(24, 5, 1, 0.600, 'kg'),
(25, 5, 2, 0.300, 'kg'),
(26, 5, 3, 0.250, 'kg'),
(27, 5, 9, 0.250, 'kg'),
(28, 5, 5, 2.000, 'pza'),
(29, 5, 6, 0.010, 'L');

-- --------------------------------------------------------

--
-- Table structure for table `ingredientes`
--

CREATE TABLE `ingredientes` (
  `id_ingrediente` int UNSIGNED NOT NULL,
  `nombre` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cantidad` decimal(12,3) NOT NULL DEFAULT '0.000',
  `unidad` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `costo_unitario` decimal(12,2) NOT NULL DEFAULT '0.00',
  `stock_minimo` decimal(12,3) NOT NULL DEFAULT '0.000',
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ;

--
-- Dumping data for table `ingredientes`
--

INSERT INTO `ingredientes` (`id_ingrediente`, `nombre`, `cantidad`, `unidad`, `costo_unitario`, `stock_minimo`, `activo`, `creado_en`, `actualizado_en`) VALUES
(1, 'Harina de trigo', 2.800, 'kg', 24.00, 10.000, 1, '2026-11-17 23:50:25', '2026-11-20 01:31:56'),
(2, 'Mantequilla sin sal', 0.100, 'kg', 145.00, 5.000, 1, '2026-11-17 23:50:25', '2026-11-20 01:31:56'),
(3, 'Azúcar mascabado', 15.000, 'kg', 32.00, 8.000, 1, '2026-11-17 23:50:25', '2026-11-20 01:31:56'),
(4, 'Chocolate belga', 1.750, 'kg', 220.00, 4.000, 1, '2026-11-17 23:50:25', '2026-11-20 01:31:56'),
(5, 'Huevos frescos', 96.000, 'pza', 3.50, 30.000, 1, '2026-11-17 23:50:25', '2026-11-20 01:31:56'),
(6, 'Esencia de vainilla', 90.380, 'L', 59.00, 1.000, 1, '2026-11-17 23:50:25', '2026-11-20 01:31:56'),
(7, 'Fresa y chocolate blanco', 12.000, 'kg', 190.00, 3.000, 1, '2026-11-17 23:50:25', '2026-11-17 23:50:25'),
(8, 'Cacao y queso crema', 7.250, 'kg', 160.00, 3.000, 1, '2026-11-17 23:50:25', '2026-11-20 01:00:05'),
(9, 'Limón y azúcar glass', 8.000, 'kg', 75.00, 2.000, 1, '2026-11-17 23:50:25', '2026-11-17 23:50:25');

-- --------------------------------------------------------

--
-- Table structure for table `inventario_productos`
--

CREATE TABLE `inventario_productos` (
  `id_inventario_producto` int UNSIGNED NOT NULL,
  `id_producto` int UNSIGNED NOT NULL,
  `existencia` int NOT NULL DEFAULT '0',
  `minimo` int NOT NULL DEFAULT '0',
  `unidades_vendidas_historicas` int UNSIGNED NOT NULL DEFAULT '0',
  `actualizado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ;

--
-- Dumping data for table `inventario_productos`
--

INSERT INTO `inventario_productos` (`id_inventario_producto`, `id_producto`, `existencia`, `minimo`, `unidades_vendidas_historicas`, `actualizado_en`) VALUES
(1, 1, 146, 10, 342, '2026-11-20 01:31:56'),
(2, 2, 86, 10, 256, '2026-11-17 23:50:25'),
(3, 3, 196, 10, 198, '2026-11-20 01:00:05'),
(4, 4, 24, 10, 164, '2026-11-17 23:50:25'),
(5, 5, 52, 10, 126, '2026-11-17 23:50:25');

-- --------------------------------------------------------

--
-- Table structure for table `metricas_marketing`
--

CREATE TABLE `metricas_marketing` (
  `id_metrica` int UNSIGNED NOT NULL,
  `id_campania` int UNSIGNED NOT NULL,
  `fecha` date NOT NULL,
  `alcance` int UNSIGNED NOT NULL DEFAULT '0',
  `impresiones` int UNSIGNED NOT NULL DEFAULT '0',
  `interacciones` int UNSIGNED NOT NULL DEFAULT '0',
  `clics` int UNSIGNED NOT NULL DEFAULT '0',
  `conversiones` int UNSIGNED NOT NULL DEFAULT '0',
  `inversion` decimal(12,2) NOT NULL DEFAULT '0.00',
  `ingresos_atribuidos` decimal(12,2) NOT NULL DEFAULT '0.00',
  `tasa_conversion` decimal(6,2) NOT NULL DEFAULT '0.00',
  `roas` decimal(8,2) NOT NULL DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `metricas_marketing`
--

INSERT INTO `metricas_marketing` (`id_metrica`, `id_campania`, `fecha`, `alcance`, `impresiones`, `interacciones`, `clics`, `conversiones`, `inversion`, `ingresos_atribuidos`, `tasa_conversion`, `roas`) VALUES
(1, 4, '2025-06-30', 48620, 48620, 6842, 0, 0, 0.00, 0.00, 4.80, 3.60),
(2, 1, '2025-06-30', 0, 0, 0, 0, 0, 0.00, 0.00, 0.00, 4.80),
(3, 2, '2025-06-30', 0, 0, 0, 0, 0, 0.00, 0.00, 0.00, 3.60),
(4, 3, '2025-06-30', 0, 0, 0, 0, 0, 0.00, 0.00, 0.00, 2.40);

-- --------------------------------------------------------

--
-- Table structure for table `movimientos_materia_prima`
--

CREATE TABLE `movimientos_materia_prima` (
  `id_movimiento` int UNSIGNED NOT NULL,
  `id_ingrediente` int UNSIGNED NOT NULL,
  `tipo` enum('entrada_compra','salida_produccion','ajuste_entrada','ajuste_salida') COLLATE utf8mb4_unicode_ci NOT NULL,
  `cantidad` decimal(12,3) NOT NULL,
  `existencia_anterior` decimal(12,3) NOT NULL,
  `existencia_nueva` decimal(12,3) NOT NULL,
  `referencia` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observaciones` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_movimiento` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_administrador` int UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `movimientos_materia_prima`
--

INSERT INTO `movimientos_materia_prima` (`id_movimiento`, `id_ingrediente`, `tipo`, `cantidad`, `existencia_anterior`, `existencia_nueva`, `referencia`, `observaciones`, `fecha_movimiento`, `id_administrador`) VALUES
(1, 1, 'ajuste_salida', 25.000, 25.000, 0.000, '1', 'Reversión de compra', '2026-11-19 18:03:34', NULL),
(2, 6, 'entrada_compra', 44.000, 2.500, 46.500, '3', '', '2026-11-19 18:35:47', NULL),
(3, 6, 'entrada_compra', 44.000, 46.500, 90.500, '4', '', '2026-11-19 18:35:47', NULL),
(4, 1, 'salida_produccion', 0.600, 10.000, 9.400, 'BC-LOT-261119185955056489', '', '2026-11-19 18:59:55', NULL),
(5, 2, 'salida_produccion', 0.300, 3.500, 3.200, 'BC-LOT-261119185955056489', '', '2026-11-19 18:59:55', NULL),
(6, 3, 'salida_produccion', 0.250, 18.000, 17.750, 'BC-LOT-261119185955056489', '', '2026-11-19 18:59:55', NULL),
(7, 5, 'salida_produccion', 2.000, 120.000, 118.000, 'BC-LOT-261119185955056489', '', '2026-11-19 18:59:55', NULL),
(8, 6, 'salida_produccion', 0.010, 90.500, 90.490, 'BC-LOT-261119185955056489', '', '2026-11-19 18:59:55', NULL),
(9, 8, 'salida_produccion', 0.250, 10.000, 9.750, 'BC-LOT-261119185955056489', '', '2026-11-19 18:59:55', NULL),
(10, 1, 'salida_produccion', 0.600, 9.400, 8.800, 'BC-LOT-261119185957888778', '', '2026-11-19 18:59:57', NULL),
(11, 2, 'salida_produccion', 0.300, 3.200, 2.900, 'BC-LOT-261119185957888778', '', '2026-11-19 18:59:57', NULL),
(12, 3, 'salida_produccion', 0.250, 17.750, 17.500, 'BC-LOT-261119185957888778', '', '2026-11-19 18:59:57', NULL),
(13, 5, 'salida_produccion', 2.000, 118.000, 116.000, 'BC-LOT-261119185957888778', '', '2026-11-19 18:59:57', NULL),
(14, 6, 'salida_produccion', 0.010, 90.490, 90.480, 'BC-LOT-261119185957888778', '', '2026-11-19 18:59:57', NULL),
(15, 8, 'salida_produccion', 0.250, 9.750, 9.500, 'BC-LOT-261119185957888778', '', '2026-11-19 18:59:57', NULL),
(16, 1, 'salida_produccion', 0.600, 8.800, 8.200, 'BC-LOT-261119190004041145', '', '2026-11-19 19:00:04', NULL),
(17, 2, 'salida_produccion', 0.300, 2.900, 2.600, 'BC-LOT-261119190004041145', '', '2026-11-19 19:00:04', NULL),
(18, 3, 'salida_produccion', 0.250, 17.500, 17.250, 'BC-LOT-261119190004041145', '', '2026-11-19 19:00:04', NULL),
(19, 5, 'salida_produccion', 2.000, 116.000, 114.000, 'BC-LOT-261119190004041145', '', '2026-11-19 19:00:04', NULL),
(20, 6, 'salida_produccion', 0.010, 90.480, 90.470, 'BC-LOT-261119190004041145', '', '2026-11-19 19:00:04', NULL),
(21, 8, 'salida_produccion', 0.250, 9.500, 9.250, 'BC-LOT-261119190004041145', '', '2026-11-19 19:00:04', NULL),
(22, 1, 'salida_produccion', 0.600, 8.200, 7.600, 'BC-LOT-261119190004227522', '', '2026-11-19 19:00:04', NULL),
(23, 2, 'salida_produccion', 0.300, 2.600, 2.300, 'BC-LOT-261119190004227522', '', '2026-11-19 19:00:04', NULL),
(24, 3, 'salida_produccion', 0.250, 17.250, 17.000, 'BC-LOT-261119190004227522', '', '2026-11-19 19:00:04', NULL),
(25, 5, 'salida_produccion', 2.000, 114.000, 112.000, 'BC-LOT-261119190004227522', '', '2026-11-19 19:00:04', NULL),
(26, 6, 'salida_produccion', 0.010, 90.470, 90.460, 'BC-LOT-261119190004227522', '', '2026-11-19 19:00:04', NULL),
(27, 8, 'salida_produccion', 0.250, 9.250, 9.000, 'BC-LOT-261119190004227522', '', '2026-11-19 19:00:04', NULL),
(28, 1, 'salida_produccion', 0.600, 7.600, 7.000, 'BC-LOT-261119190004381473', '', '2026-11-19 19:00:04', NULL),
(29, 2, 'salida_produccion', 0.300, 2.300, 2.000, 'BC-LOT-261119190004381473', '', '2026-11-19 19:00:04', NULL),
(30, 3, 'salida_produccion', 0.250, 17.000, 16.750, 'BC-LOT-261119190004381473', '', '2026-11-19 19:00:04', NULL),
(31, 5, 'salida_produccion', 2.000, 112.000, 110.000, 'BC-LOT-261119190004381473', '', '2026-11-19 19:00:04', NULL),
(32, 6, 'salida_produccion', 0.010, 90.460, 90.450, 'BC-LOT-261119190004381473', '', '2026-11-19 19:00:04', NULL),
(33, 8, 'salida_produccion', 0.250, 9.000, 8.750, 'BC-LOT-261119190004381473', '', '2026-11-19 19:00:04', NULL),
(34, 1, 'salida_produccion', 0.600, 7.000, 6.400, 'BC-LOT-261119190004506692', '', '2026-11-19 19:00:04', NULL),
(35, 2, 'salida_produccion', 0.300, 2.000, 1.700, 'BC-LOT-261119190004506692', '', '2026-11-19 19:00:04', NULL),
(36, 3, 'salida_produccion', 0.250, 16.750, 16.500, 'BC-LOT-261119190004506692', '', '2026-11-19 19:00:04', NULL),
(37, 5, 'salida_produccion', 2.000, 110.000, 108.000, 'BC-LOT-261119190004506692', '', '2026-11-19 19:00:04', NULL),
(38, 6, 'salida_produccion', 0.010, 90.450, 90.440, 'BC-LOT-261119190004506692', '', '2026-11-19 19:00:04', NULL),
(39, 8, 'salida_produccion', 0.250, 8.750, 8.500, 'BC-LOT-261119190004506692', '', '2026-11-19 19:00:04', NULL),
(40, 1, 'salida_produccion', 0.600, 6.400, 5.800, 'BC-LOT-261119190004650188', '', '2026-11-19 19:00:04', NULL),
(41, 2, 'salida_produccion', 0.300, 1.700, 1.400, 'BC-LOT-261119190004650188', '', '2026-11-19 19:00:04', NULL),
(42, 3, 'salida_produccion', 0.250, 16.500, 16.250, 'BC-LOT-261119190004650188', '', '2026-11-19 19:00:04', NULL),
(43, 5, 'salida_produccion', 2.000, 108.000, 106.000, 'BC-LOT-261119190004650188', '', '2026-11-19 19:00:04', NULL),
(44, 6, 'salida_produccion', 0.010, 90.440, 90.430, 'BC-LOT-261119190004650188', '', '2026-11-19 19:00:04', NULL),
(45, 8, 'salida_produccion', 0.250, 8.500, 8.250, 'BC-LOT-261119190004650188', '', '2026-11-19 19:00:04', NULL),
(46, 1, 'salida_produccion', 0.600, 5.800, 5.200, 'BC-LOT-261119190004838603', '', '2026-11-19 19:00:04', NULL),
(47, 2, 'salida_produccion', 0.300, 1.400, 1.100, 'BC-LOT-261119190004838603', '', '2026-11-19 19:00:04', NULL),
(48, 3, 'salida_produccion', 0.250, 16.250, 16.000, 'BC-LOT-261119190004838603', '', '2026-11-19 19:00:04', NULL),
(49, 5, 'salida_produccion', 2.000, 106.000, 104.000, 'BC-LOT-261119190004838603', '', '2026-11-19 19:00:04', NULL),
(50, 6, 'salida_produccion', 0.010, 90.430, 90.420, 'BC-LOT-261119190004838603', '', '2026-11-19 19:00:04', NULL),
(51, 8, 'salida_produccion', 0.250, 8.250, 8.000, 'BC-LOT-261119190004838603', '', '2026-11-19 19:00:04', NULL),
(52, 1, 'salida_produccion', 0.600, 5.200, 4.600, 'BC-LOT-261119190005033988', '', '2026-11-19 19:00:05', NULL),
(53, 2, 'salida_produccion', 0.300, 1.100, 0.800, 'BC-LOT-261119190005033988', '', '2026-11-19 19:00:05', NULL),
(54, 3, 'salida_produccion', 0.250, 16.000, 15.750, 'BC-LOT-261119190005033988', '', '2026-11-19 19:00:05', NULL),
(55, 5, 'salida_produccion', 2.000, 104.000, 102.000, 'BC-LOT-261119190005033988', '', '2026-11-19 19:00:05', NULL),
(56, 6, 'salida_produccion', 0.010, 90.420, 90.410, 'BC-LOT-261119190005033988', '', '2026-11-19 19:00:05', NULL),
(57, 8, 'salida_produccion', 0.250, 8.000, 7.750, 'BC-LOT-261119190005033988', '', '2026-11-19 19:00:05', NULL),
(58, 1, 'salida_produccion', 0.600, 4.600, 4.000, 'BC-LOT-261119190005242056', '', '2026-11-19 19:00:05', NULL),
(59, 2, 'salida_produccion', 0.300, 0.800, 0.500, 'BC-LOT-261119190005242056', '', '2026-11-19 19:00:05', NULL),
(60, 3, 'salida_produccion', 0.250, 15.750, 15.500, 'BC-LOT-261119190005242056', '', '2026-11-19 19:00:05', NULL),
(61, 5, 'salida_produccion', 2.000, 102.000, 100.000, 'BC-LOT-261119190005242056', '', '2026-11-19 19:00:05', NULL),
(62, 6, 'salida_produccion', 0.010, 90.410, 90.400, 'BC-LOT-261119190005242056', '', '2026-11-19 19:00:05', NULL),
(63, 8, 'salida_produccion', 0.250, 7.750, 7.500, 'BC-LOT-261119190005242056', '', '2026-11-19 19:00:05', NULL),
(64, 1, 'salida_produccion', 0.600, 4.000, 3.400, 'BC-LOT-261119190005403153', '', '2026-11-19 19:00:05', NULL),
(65, 2, 'salida_produccion', 0.300, 0.500, 0.200, 'BC-LOT-261119190005403153', '', '2026-11-19 19:00:05', NULL),
(66, 3, 'salida_produccion', 0.250, 15.500, 15.250, 'BC-LOT-261119190005403153', '', '2026-11-19 19:00:05', NULL),
(67, 5, 'salida_produccion', 2.000, 100.000, 98.000, 'BC-LOT-261119190005403153', '', '2026-11-19 19:00:05', NULL),
(68, 6, 'salida_produccion', 0.010, 90.400, 90.390, 'BC-LOT-261119190005403153', '', '2026-11-19 19:00:05', NULL),
(69, 8, 'salida_produccion', 0.250, 7.500, 7.250, 'BC-LOT-261119190005403153', '', '2026-11-19 19:00:05', NULL),
(70, 1, 'salida_produccion', 0.600, 3.400, 2.800, 'BC-LOT-261119193156240257', '', '2026-11-19 19:31:56', NULL),
(71, 2, 'salida_produccion', 0.300, 0.400, 0.100, 'BC-LOT-261119193156240257', '', '2026-11-19 19:31:56', NULL),
(72, 3, 'salida_produccion', 0.250, 15.250, 15.000, 'BC-LOT-261119193156240257', '', '2026-11-19 19:31:56', NULL),
(73, 4, 'salida_produccion', 0.250, 2.000, 1.750, 'BC-LOT-261119193156240257', '', '2026-11-19 19:31:56', NULL),
(74, 5, 'salida_produccion', 2.000, 98.000, 96.000, 'BC-LOT-261119193156240257', '', '2026-11-19 19:31:56', NULL),
(75, 6, 'salida_produccion', 0.010, 90.390, 90.380, 'BC-LOT-261119193156240257', '', '2026-11-19 19:31:56', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `movimientos_producto_terminado`
--

CREATE TABLE `movimientos_producto_terminado` (
  `id_movimiento` int UNSIGNED NOT NULL,
  `id_producto` int UNSIGNED NOT NULL,
  `tipo` enum('entrada_produccion','salida_venta','ajuste_entrada','ajuste_salida') COLLATE utf8mb4_unicode_ci NOT NULL,
  `cantidad` int NOT NULL,
  `existencia_anterior` int NOT NULL,
  `existencia_nueva` int NOT NULL,
  `referencia` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observaciones` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_movimiento` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_administrador` int UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `movimientos_producto_terminado`
--

INSERT INTO `movimientos_producto_terminado` (`id_movimiento`, `id_producto`, `tipo`, `cantidad`, `existencia_anterior`, `existencia_nueva`, `referencia`, `observaciones`, `fecha_movimiento`, `id_administrador`) VALUES
(1, 1, 'ajuste_entrada', 6, 128, 134, 'BC-1028', 'Reversión de pedido cancelado', '2026-11-18 18:37:31', NULL),
(2, 3, 'entrada_produccion', 12, 64, 76, 'BC-LOT-261119185955056489', '', '2026-11-19 18:59:55', NULL),
(3, 3, 'entrada_produccion', 12, 76, 88, 'BC-LOT-261119185957888778', '', '2026-11-19 18:59:57', NULL),
(4, 3, 'entrada_produccion', 12, 88, 100, 'BC-LOT-261119190004041145', '', '2026-11-19 19:00:04', NULL),
(5, 3, 'entrada_produccion', 12, 100, 112, 'BC-LOT-261119190004227522', '', '2026-11-19 19:00:04', NULL),
(6, 3, 'entrada_produccion', 12, 112, 124, 'BC-LOT-261119190004381473', '', '2026-11-19 19:00:04', NULL),
(7, 3, 'entrada_produccion', 12, 124, 136, 'BC-LOT-261119190004506692', '', '2026-11-19 19:00:04', NULL),
(8, 3, 'entrada_produccion', 12, 136, 148, 'BC-LOT-261119190004650188', '', '2026-11-19 19:00:04', NULL),
(9, 3, 'entrada_produccion', 12, 148, 160, 'BC-LOT-261119190004838603', '', '2026-11-19 19:00:04', NULL),
(10, 3, 'entrada_produccion', 12, 160, 172, 'BC-LOT-261119190005033988', '', '2026-11-19 19:00:05', NULL),
(11, 3, 'entrada_produccion', 12, 172, 184, 'BC-LOT-261119190005242056', '', '2026-11-19 19:00:05', NULL),
(12, 3, 'entrada_produccion', 12, 184, 196, 'BC-LOT-261119190005403153', '', '2026-11-19 19:00:05', NULL),
(13, 1, 'entrada_produccion', 12, 134, 146, 'BC-LOT-261119193156240257', '', '2026-11-19 19:31:56', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pedidos`
--

CREATE TABLE `pedidos` (
  `id_pedido` int UNSIGNED NOT NULL,
  `codigo_pedido` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_cliente` int UNSIGNED DEFAULT NULL,
  `nombre_cliente` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correo_cliente` varchar(160) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono_cliente` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `direccion_entrega` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_pedido` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `subtotal` decimal(12,2) NOT NULL DEFAULT '0.00',
  `costo_envio` decimal(10,2) NOT NULL DEFAULT '0.00',
  `descuento` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `estado` enum('pendiente','en_preparacion','completado','cancelado') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pendiente',
  `mensaje_regalo` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `es_demo` tinyint(1) NOT NULL DEFAULT '0',
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ;

--
-- Dumping data for table `pedidos`
--

INSERT INTO `pedidos` (`id_pedido`, `codigo_pedido`, `id_cliente`, `nombre_cliente`, `correo_cliente`, `telefono_cliente`, `direccion_entrega`, `fecha_pedido`, `subtotal`, `costo_envio`, `descuento`, `total`, `estado`, `mensaje_regalo`, `es_demo`, `creado_en`, `actualizado_en`) VALUES
(1025, 'BC-1025', 4, 'Luis Hernández', NULL, NULL, NULL, '2026-11-17 17:25:25', 300.00, 0.00, 0.00, 300.00, 'en_preparacion', NULL, 1, '2026-11-17 23:50:25', '2026-11-19 00:29:58'),
(1026, 'BC-1026', 3, 'Ana Martínez', NULL, NULL, NULL, '2026-11-17 17:32:25', 192.00, 0.00, 0.00, 192.00, 'en_preparacion', NULL, 1, '2026-11-17 23:50:25', '2026-11-19 00:29:53'),
(1027, 'BC-1027', 2, 'Carlos Mendoza', NULL, NULL, NULL, '2026-11-17 17:38:25', 540.00, 0.00, 0.00, 540.00, 'en_preparacion', NULL, 1, '2026-11-17 23:50:25', '2026-11-17 23:50:25'),
(1028, 'BC-1028', 1, 'María García', NULL, NULL, NULL, '2026-11-17 17:45:25', 270.00, 0.00, 0.00, 270.00, 'cancelado', NULL, 1, '2026-11-17 23:50:25', '2026-11-19 00:37:31');

-- --------------------------------------------------------

--
-- Table structure for table `preferencias_productos`
--

CREATE TABLE `preferencias_productos` (
  `id_preferencia` int UNSIGNED NOT NULL,
  `id_producto` int UNSIGNED NOT NULL,
  `porcentaje` decimal(5,2) NOT NULL DEFAULT '0.00',
  `respuestas` int UNSIGNED NOT NULL DEFAULT '0',
  `periodo` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `es_demo` tinyint(1) NOT NULL DEFAULT '0'
) ;

--
-- Dumping data for table `preferencias_productos`
--

INSERT INTO `preferencias_productos` (`id_preferencia`, `id_producto`, `porcentaje`, `respuestas`, `periodo`, `es_demo`) VALUES
(1, 1, 32.00, 1086, 'Junio 2025', 1),
(2, 2, 24.00, 1086, 'Junio 2025', 1),
(3, 3, 18.00, 1086, 'Junio 2025', 1),
(4, 4, 15.00, 1086, 'Junio 2025', 1),
(5, 5, 11.00, 1086, 'Junio 2025', 1);

-- --------------------------------------------------------

--
-- Table structure for table `producciones`
--

CREATE TABLE `producciones` (
  `id_produccion` int UNSIGNED NOT NULL,
  `codigo_lote` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_producto` int UNSIGNED NOT NULL,
  `id_receta` int UNSIGNED NOT NULL,
  `cantidad_lotes` int UNSIGNED NOT NULL DEFAULT '1',
  `unidades_producidas` int UNSIGNED NOT NULL,
  `fecha_produccion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` enum('completada','cancelada') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'completada',
  `observaciones` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `creado_por` int UNSIGNED DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ;

--
-- Dumping data for table `producciones`
--

INSERT INTO `producciones` (`id_produccion`, `codigo_lote`, `id_producto`, `id_receta`, `cantidad_lotes`, `unidades_producidas`, `fecha_produccion`, `estado`, `observaciones`, `creado_por`, `creado_en`) VALUES
(12, 'BC-LOT-261119193156240257', 1, 1, 1, 12, '2026-11-19 19:31:56', 'completada', '', NULL, '2026-11-20 01:31:56');

-- --------------------------------------------------------

--
-- Table structure for table `productos`
--

CREATE TABLE `productos` (
  `id_producto` int UNSIGNED NOT NULL,
  `nombre` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `precio` decimal(10,2) NOT NULL DEFAULT '0.00',
  `imagen` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `color_hex` char(7) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `etiqueta` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ;

--
-- Dumping data for table `productos`
--

INSERT INTO `productos` (`id_producto`, `nombre`, `descripcion`, `precio`, `imagen`, `color_hex`, `etiqueta`, `activo`, `creado_en`, `actualizado_en`) VALUES
(1, 'Bubble Choco', 'Nuestra clásica galleta con generosos trozos de chocolate belga.', 45.00, '/assets/bubblecookies/cookies/bubble-choco.png', '#8cc0eb', 'La favorita', 1, '2026-11-17 23:50:25', '2026-11-17 23:50:25'),
(2, 'Double Fresa', 'Doble dosis de fresa y chocolate blanco. Amor a primera mordida.', 48.00, '/assets/bubblecookies/cookies/double-fresa.png', '#efbaca', 'Dulce y especial', 1, '2026-11-17 23:50:25', '2026-11-17 23:50:25'),
(3, 'Red Velvet', 'Suave cacao rojo con un corazón cremoso de queso.', 50.00, '/assets/bubblecookies/cookies/red-velvet.png', '#ba8f91', 'Irresistible', 1, '2026-11-17 23:50:25', '2026-11-17 23:50:25'),
(4, 'Butter Cookies', 'Mantequilla de verdad, bordes doraditos y mucho cariño.', 38.00, '/assets/bubblecookies/cookies/butter-cookies.png', '#e9d39d', 'Un clásico', 1, '2026-11-17 23:50:25', '2026-11-17 23:50:25'),
(5, 'Lemon Glass', 'Un toque de limón fresco bajo un delicado glaseado artesanal.', 45.00, '/assets/bubblecookies/cookies/lemon-glass.png', '#bfc7a3', 'Un toque fresco', 1, '2026-11-17 23:50:25', '2026-11-17 23:50:25');

-- --------------------------------------------------------

--
-- Table structure for table `proveedores`
--

CREATE TABLE `proveedores` (
  `id_proveedor` int UNSIGNED NOT NULL,
  `nombre` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contacto` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correo` varchar(160) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `direccion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `proveedores`
--

INSERT INTO `proveedores` (`id_proveedor`, `nombre`, `contacto`, `telefono`, `correo`, `direccion`, `activo`, `creado_en`) VALUES
(1, 'Molinos del Valle', NULL, NULL, NULL, NULL, 1, '2026-11-17 23:50:25'),
(2, 'Lácteos La Pradera', NULL, NULL, NULL, NULL, 1, '2026-11-17 23:50:25'),
(4, 'Maria', '33333333333333', '4775866997', 'eerre', NULL, 1, '2026-11-20 00:35:13');

-- --------------------------------------------------------

--
-- Table structure for table `recetas`
--

CREATE TABLE `recetas` (
  `id_receta` int UNSIGNED NOT NULL,
  `id_producto` int UNSIGNED NOT NULL,
  `nombre` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `unidades_por_lote` int UNSIGNED NOT NULL DEFAULT '12',
  `instrucciones` text COLLATE utf8mb4_unicode_ci,
  `activa` tinyint(1) NOT NULL DEFAULT '1',
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `recetas`
--

INSERT INTO `recetas` (`id_receta`, `id_producto`, `nombre`, `unidades_por_lote`, `instrucciones`, `activa`, `creado_en`, `actualizado_en`) VALUES
(1, 1, 'Receta Bubble Choco', 12, 'Receta inicial de demostración migrada desde BUBBLE.zip.', 1, '2026-11-17 23:50:25', '2026-11-17 23:50:25'),
(2, 2, 'Receta Double Fresa', 12, 'Receta inicial de demostración migrada desde BUBBLE.zip.', 1, '2026-11-17 23:50:25', '2026-11-17 23:50:25'),
(3, 3, 'Receta Red Velvet', 12, 'Receta inicial de demostración migrada desde BUBBLE.zip.', 1, '2026-11-17 23:50:25', '2026-11-17 23:50:25'),
(4, 4, 'Receta Butter Cookies', 12, 'Receta inicial de demostración migrada desde BUBBLE.zip.', 1, '2026-11-17 23:50:25', '2026-11-17 23:50:25'),
(5, 5, 'Receta Lemon Glass', 12, 'Receta inicial de demostración migrada desde BUBBLE.zip.', 1, '2026-11-17 23:50:25', '2026-11-17 23:50:25');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `administradores`
--
ALTER TABLE `administradores`
  ADD PRIMARY KEY (`id_administrador`),
  ADD UNIQUE KEY `correo` (`correo`);

--
-- Indexes for table `campanias_marketing`
--
ALTER TABLE `campanias_marketing`
  ADD PRIMARY KEY (`id_campania`);

--
-- Indexes for table `carritos`
--
ALTER TABLE `carritos`
  ADD PRIMARY KEY (`id_carrito`),
  ADD UNIQUE KEY `token_sesion` (`token_sesion`),
  ADD KEY `fk_carrito_cliente` (`id_cliente`);

--
-- Indexes for table `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`id_cliente`),
  ADD UNIQUE KEY `correo` (`correo`);

--
-- Indexes for table `compras`
--
ALTER TABLE `compras`
  ADD PRIMARY KEY (`id_compra`),
  ADD KEY `fk_compra_proveedor` (`id_proveedor`),
  ADD KEY `fk_compra_admin` (`creada_por`),
  ADD KEY `idx_compras_fecha` (`fecha_compra`);

--
-- Indexes for table `detalle_carrito`
--
ALTER TABLE `detalle_carrito`
  ADD PRIMARY KEY (`id_detalle_carrito`),
  ADD UNIQUE KEY `uq_detcar_producto` (`id_carrito`,`id_producto`),
  ADD KEY `fk_detcar_producto` (`id_producto`);

--
-- Indexes for table `detalle_compras`
--
ALTER TABLE `detalle_compras`
  ADD PRIMARY KEY (`id_detalle_compra`),
  ADD KEY `fk_detcomp_compra` (`id_compra`),
  ADD KEY `fk_detcomp_ingrediente` (`id_ingrediente`);

--
-- Indexes for table `detalle_consumo_produccion`
--
ALTER TABLE `detalle_consumo_produccion`
  ADD PRIMARY KEY (`id_consumo`),
  ADD KEY `fk_consumo_produccion` (`id_produccion`),
  ADD KEY `fk_consumo_ingrediente` (`id_ingrediente`);

--
-- Indexes for table `detalle_pedidos`
--
ALTER TABLE `detalle_pedidos`
  ADD PRIMARY KEY (`id_detalle_pedido`),
  ADD KEY `fk_detpedido_pedido` (`id_pedido`),
  ADD KEY `fk_detpedido_producto` (`id_producto`);

--
-- Indexes for table `detalle_recetas`
--
ALTER TABLE `detalle_recetas`
  ADD PRIMARY KEY (`id_detalle_receta`),
  ADD UNIQUE KEY `uq_detrec_receta_ingrediente` (`id_receta`,`id_ingrediente`),
  ADD KEY `fk_detrec_ingrediente` (`id_ingrediente`);

--
-- Indexes for table `ingredientes`
--
ALTER TABLE `ingredientes`
  ADD PRIMARY KEY (`id_ingrediente`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indexes for table `inventario_productos`
--
ALTER TABLE `inventario_productos`
  ADD PRIMARY KEY (`id_inventario_producto`),
  ADD UNIQUE KEY `id_producto` (`id_producto`);

--
-- Indexes for table `metricas_marketing`
--
ALTER TABLE `metricas_marketing`
  ADD PRIMARY KEY (`id_metrica`),
  ADD UNIQUE KEY `uq_metrica_campania_fecha` (`id_campania`,`fecha`),
  ADD KEY `idx_metricas_fecha` (`fecha`);

--
-- Indexes for table `movimientos_materia_prima`
--
ALTER TABLE `movimientos_materia_prima`
  ADD PRIMARY KEY (`id_movimiento`),
  ADD KEY `fk_movmat_ingrediente` (`id_ingrediente`),
  ADD KEY `fk_movmat_admin` (`id_administrador`),
  ADD KEY `idx_movmat_fecha` (`fecha_movimiento`);

--
-- Indexes for table `movimientos_producto_terminado`
--
ALTER TABLE `movimientos_producto_terminado`
  ADD PRIMARY KEY (`id_movimiento`),
  ADD KEY `fk_movprod_producto` (`id_producto`),
  ADD KEY `fk_movprod_admin` (`id_administrador`),
  ADD KEY `idx_movprod_fecha` (`fecha_movimiento`);

--
-- Indexes for table `pedidos`
--
ALTER TABLE `pedidos`
  ADD PRIMARY KEY (`id_pedido`),
  ADD UNIQUE KEY `codigo_pedido` (`codigo_pedido`),
  ADD KEY `fk_pedido_cliente` (`id_cliente`),
  ADD KEY `idx_pedidos_fecha` (`fecha_pedido`),
  ADD KEY `idx_pedidos_estado` (`estado`);

--
-- Indexes for table `preferencias_productos`
--
ALTER TABLE `preferencias_productos`
  ADD PRIMARY KEY (`id_preferencia`),
  ADD UNIQUE KEY `id_producto` (`id_producto`);

--
-- Indexes for table `producciones`
--
ALTER TABLE `producciones`
  ADD PRIMARY KEY (`id_produccion`),
  ADD UNIQUE KEY `codigo_lote` (`codigo_lote`),
  ADD KEY `fk_produccion_producto` (`id_producto`),
  ADD KEY `fk_produccion_receta` (`id_receta`),
  ADD KEY `fk_produccion_admin` (`creado_por`),
  ADD KEY `idx_producciones_fecha` (`fecha_produccion`);

--
-- Indexes for table `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id_producto`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indexes for table `proveedores`
--
ALTER TABLE `proveedores`
  ADD PRIMARY KEY (`id_proveedor`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indexes for table `recetas`
--
ALTER TABLE `recetas`
  ADD PRIMARY KEY (`id_receta`),
  ADD UNIQUE KEY `id_producto` (`id_producto`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `administradores`
--
ALTER TABLE `administradores`
  MODIFY `id_administrador` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `campanias_marketing`
--
ALTER TABLE `campanias_marketing`
  MODIFY `id_campania` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `carritos`
--
ALTER TABLE `carritos`
  MODIFY `id_carrito` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id_cliente` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `compras`
--
ALTER TABLE `compras`
  MODIFY `id_compra` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `detalle_carrito`
--
ALTER TABLE `detalle_carrito`
  MODIFY `id_detalle_carrito` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `detalle_compras`
--
ALTER TABLE `detalle_compras`
  MODIFY `id_detalle_compra` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `detalle_consumo_produccion`
--
ALTER TABLE `detalle_consumo_produccion`
  MODIFY `id_consumo` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `detalle_pedidos`
--
ALTER TABLE `detalle_pedidos`
  MODIFY `id_detalle_pedido` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `detalle_recetas`
--
ALTER TABLE `detalle_recetas`
  MODIFY `id_detalle_receta` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ingredientes`
--
ALTER TABLE `ingredientes`
  MODIFY `id_ingrediente` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventario_productos`
--
ALTER TABLE `inventario_productos`
  MODIFY `id_inventario_producto` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `metricas_marketing`
--
ALTER TABLE `metricas_marketing`
  MODIFY `id_metrica` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `movimientos_materia_prima`
--
ALTER TABLE `movimientos_materia_prima`
  MODIFY `id_movimiento` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=76;

--
-- AUTO_INCREMENT for table `movimientos_producto_terminado`
--
ALTER TABLE `movimientos_producto_terminado`
  MODIFY `id_movimiento` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `pedidos`
--
ALTER TABLE `pedidos`
  MODIFY `id_pedido` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `preferencias_productos`
--
ALTER TABLE `preferencias_productos`
  MODIFY `id_preferencia` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `producciones`
--
ALTER TABLE `producciones`
  MODIFY `id_produccion` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `productos`
--
ALTER TABLE `productos`
  MODIFY `id_producto` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `id_proveedor` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `recetas`
--
ALTER TABLE `recetas`
  MODIFY `id_receta` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `carritos`
--
ALTER TABLE `carritos`
  ADD CONSTRAINT `fk_carrito_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`);

--
-- Constraints for table `compras`
--
ALTER TABLE `compras`
  ADD CONSTRAINT `fk_compra_admin` FOREIGN KEY (`creada_por`) REFERENCES `administradores` (`id_administrador`),
  ADD CONSTRAINT `fk_compra_proveedor` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedores` (`id_proveedor`);

--
-- Constraints for table `detalle_carrito`
--
ALTER TABLE `detalle_carrito`
  ADD CONSTRAINT `fk_detcar_carrito` FOREIGN KEY (`id_carrito`) REFERENCES `carritos` (`id_carrito`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_detcar_producto` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Constraints for table `detalle_compras`
--
ALTER TABLE `detalle_compras`
  ADD CONSTRAINT `fk_detcomp_compra` FOREIGN KEY (`id_compra`) REFERENCES `compras` (`id_compra`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_detcomp_ingrediente` FOREIGN KEY (`id_ingrediente`) REFERENCES `ingredientes` (`id_ingrediente`);

--
-- Constraints for table `detalle_consumo_produccion`
--
ALTER TABLE `detalle_consumo_produccion`
  ADD CONSTRAINT `fk_consumo_ingrediente` FOREIGN KEY (`id_ingrediente`) REFERENCES `ingredientes` (`id_ingrediente`),
  ADD CONSTRAINT `fk_consumo_produccion` FOREIGN KEY (`id_produccion`) REFERENCES `producciones` (`id_produccion`) ON DELETE CASCADE;

--
-- Constraints for table `detalle_pedidos`
--
ALTER TABLE `detalle_pedidos`
  ADD CONSTRAINT `fk_detpedido_pedido` FOREIGN KEY (`id_pedido`) REFERENCES `pedidos` (`id_pedido`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_detpedido_producto` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Constraints for table `detalle_recetas`
--
ALTER TABLE `detalle_recetas`
  ADD CONSTRAINT `fk_detrec_ingrediente` FOREIGN KEY (`id_ingrediente`) REFERENCES `ingredientes` (`id_ingrediente`),
  ADD CONSTRAINT `fk_detrec_receta` FOREIGN KEY (`id_receta`) REFERENCES `recetas` (`id_receta`) ON DELETE CASCADE;

--
-- Constraints for table `inventario_productos`
--
ALTER TABLE `inventario_productos`
  ADD CONSTRAINT `fk_invprod_producto` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Constraints for table `metricas_marketing`
--
ALTER TABLE `metricas_marketing`
  ADD CONSTRAINT `fk_metrica_campania` FOREIGN KEY (`id_campania`) REFERENCES `campanias_marketing` (`id_campania`) ON DELETE CASCADE;

--
-- Constraints for table `movimientos_materia_prima`
--
ALTER TABLE `movimientos_materia_prima`
  ADD CONSTRAINT `fk_movmat_admin` FOREIGN KEY (`id_administrador`) REFERENCES `administradores` (`id_administrador`),
  ADD CONSTRAINT `fk_movmat_ingrediente` FOREIGN KEY (`id_ingrediente`) REFERENCES `ingredientes` (`id_ingrediente`);

--
-- Constraints for table `movimientos_producto_terminado`
--
ALTER TABLE `movimientos_producto_terminado`
  ADD CONSTRAINT `fk_movprod_admin` FOREIGN KEY (`id_administrador`) REFERENCES `administradores` (`id_administrador`),
  ADD CONSTRAINT `fk_movprod_producto` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Constraints for table `pedidos`
--
ALTER TABLE `pedidos`
  ADD CONSTRAINT `fk_pedido_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`);

--
-- Constraints for table `preferencias_productos`
--
ALTER TABLE `preferencias_productos`
  ADD CONSTRAINT `fk_preferencia_producto` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Constraints for table `producciones`
--
ALTER TABLE `producciones`
  ADD CONSTRAINT `fk_produccion_admin` FOREIGN KEY (`creado_por`) REFERENCES `administradores` (`id_administrador`),
  ADD CONSTRAINT `fk_produccion_producto` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`),
  ADD CONSTRAINT `fk_produccion_receta` FOREIGN KEY (`id_receta`) REFERENCES `recetas` (`id_receta`);

--
-- Constraints for table `recetas`
--
ALTER TABLE `recetas`
  ADD CONSTRAINT `fk_receta_producto` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
