-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Nov 25, 2026 at 01:56 PM
-- Server version: 8.4.3
-- PHP Version: 8.3.16

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
(1, 'Cocinero BubbleCookies', 'cocina@bubblecookies.com', 'scrypt:32768:8:1$JwGKqF1NLE8tkk4g$24a6271a1325ac6bd2d09a0bcec3bd419dfe555f0d998736ee07b620d07200acb86ae66d0a0b609037d2bd994aca65dc1ef6b84e4c1b44fd740077aadd8ac47c', 'cocinero', 1, '2026-11-20 21:49:52', '2026-11-21 02:15:20', '2026-11-21 03:49:52'),
(2, 'Marketing BubbleCookies', 'marketing@bubblecookies.com', 'scrypt:32768:8:1$xJepmRsaKsptT4pi$d422e3e047c16a77cd99e281a2eefa0b7784ea303d64e7130c9334a290045cdadafe93c8b7ab4c719eebeaf8afb091b5cc1cbc8399719de30ee2c566d78720a7', 'marketing', 1, '2026-11-20 21:49:05', '2026-11-21 02:15:20', '2026-11-21 03:49:05'),
(3, 'Administrador BubbleCookies', 'admin@bubblecookies.com', 'scrypt:32768:8:1$PraYM7Ag0Z8lkGVo$8ff365c3aa00123d890c5b54f69f1d07c70ec91ce7f09d72fc1791ce066b274c892e2169a15864b6fb10d2887f7a21ca2ccc61200c24a7615509495d110cd652', 'superadmin', 1, '2026-11-25 07:42:16', '2026-11-21 02:15:21', '2026-11-25 13:42:16');

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
(1, 'Campaña Instagram - BubbleCookies', 'Instagram', '2025-06-01', '2025-06-30', 0.00, 'finalizada', 1, '2026-11-21 02:14:11'),
(2, 'Campaña TikTok - BubbleCookies', 'TikTok', '2025-06-01', '2025-06-30', 0.00, 'finalizada', 1, '2026-11-21 02:14:11'),
(3, 'Campaña Mercado Libre - BubbleCookies', 'Mercado Libre', '2025-06-01', '2025-06-30', 0.00, 'finalizada', 1, '2026-11-21 02:14:11'),
(4, 'Resumen general de campañas (demo)', 'General', '2025-06-01', '2025-06-30', 0.00, 'finalizada', 1, '2026-11-21 02:14:11'),
(6, 'SSSSSSS', 'Otro', '2026-11-01', '2026-11-21', 5999.00, 'planeada', 0, '2026-11-21 03:23:06');

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
(1, NULL, 'bubblecookies-session', 'activo', '2026-11-21 02:14:51', '2026-11-21 02:14:51');

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
(1, 'María', 'García', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(2, 'Carlos', 'Mendoza', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(3, 'Ana', 'Martínez', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(4, 'Luis', 'Hernández', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(5, 'Asael', 'Santiago', 'sasael480@gmail.com', '+524426805849', 'scrypt:32768:8:1$wAHHmLkuNelW09vS$7b74693f9401256577f1ae736b9335d10fb784f4845c23ed27d40196ff86ac1aa23b7f338129f3ef147804b8edf226a5cfcfa92ca53f057fa14004cd9da669e9', NULL, NULL, NULL, NULL, NULL, 1, '2026-11-21 03:19:18', '2026-11-21 03:19:18'),
(6, 'Mary', NULL, 'mary@gmail.com', '4776655447', 'scrypt:32768:8:1$7CXsrHprgndeuzbP$a685475ae4d2f9fd0c99f5335a72f003dca53620f3cc5469e19050fc9c27d87fec739a08e347a5d06b104a738a1e6db6b4a4ff31d3190c92a7c6ef6dce94ecc6', NULL, NULL, NULL, NULL, NULL, 1, '2026-11-25 00:12:36', '2026-11-25 00:12:36');

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
(1, 1, '2025-06-18 12:00:00', 600.00, 'recibida', 'Compra histórica de demostración; inventario inicial ya refleja las existencias actuales.', NULL, '2026-11-21 02:14:11'),
(2, 2, '2025-06-17 12:00:00', 1450.00, 'recibida', 'Compra histórica de demostración; inventario inicial ya refleja las existencias actuales.', NULL, '2026-11-21 02:14:11'),
(3, 2, '2026-11-20 21:24:51', 24.00, 'recibida', 'HAZLO YA', NULL, '2026-11-21 03:24:51'),
(4, 4, '2026-11-24 17:55:38', 50000.00, 'recibida', '', NULL, '2026-11-24 23:55:38'),
(5, 4, '2026-11-24 17:57:11', 30.00, 'recibida', '', NULL, '2026-11-24 23:57:11');

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
(3, 3, 3, 2.000, 12.00, 24.00),
(4, 4, 10, 100.000, 500.00, 50000.00),
(5, 5, 10, 1.000, 30.00, 30.00);

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
(1, 1, 1, 0.600, 'kg', 24.00),
(2, 1, 2, 0.550, 'kg', 145.00),
(3, 1, 3, 0.250, 'kg', 12.00),
(4, 1, 5, 2.000, 'pza', 3.50),
(5, 1, 6, 0.010, 'L', 180.00),
(6, 2, 1, 0.600, 'kg', 24.00),
(7, 2, 2, 0.300, 'kg', 145.00),
(8, 2, 3, 0.250, 'kg', 12.00),
(9, 2, 4, 0.280, 'kg', 220.00),
(10, 2, 5, 2.000, 'pza', 3.50),
(11, 2, 6, 0.010, 'L', 180.00),
(12, 3, 1, 1.200, 'kg', 24.00),
(13, 3, 2, 0.600, 'kg', 145.00),
(14, 3, 3, 0.500, 'kg', 12.00),
(15, 3, 5, 4.000, 'pza', 3.50),
(16, 3, 6, 0.020, 'L', 180.00),
(17, 3, 9, 0.500, 'kg', 75.00),
(18, 4, 1, 0.600, 'kg', 24.00),
(19, 4, 2, 0.300, 'kg', 145.00),
(20, 4, 3, 0.250, 'kg', 12.00),
(21, 4, 5, 2.000, 'pza', 3.50),
(22, 4, 6, 0.010, 'L', 180.00),
(23, 4, 9, 0.250, 'kg', 75.00),
(24, 5, 1, 1.800, 'kg', 24.00),
(25, 5, 2, 0.900, 'kg', 145.00),
(26, 5, 3, 0.750, 'kg', 12.00),
(27, 5, 5, 6.000, 'pza', 3.50),
(28, 5, 6, 0.030, 'L', 180.00),
(29, 5, 9, 0.750, 'kg', 75.00);

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
(4, 1025, 3, 'Red Velvet', 6, 50.00, 300.00),
(5, 1029, 1, 'Bubble Choco', 1, 45.00, 45.00),
(6, 1029, 3, 'Red Velvet', 1, 50.00, 50.00),
(7, 1029, 4, 'Butter Cookies', 1, 38.00, 38.00),
(8, 1029, 5, 'Lemon Glass', 2, 45.00, 90.00),
(9, 1030, 3, 'Red Velvet', 1, 50.00, 50.00),
(10, 1030, 5, 'Lemon Glass', 1, 45.00, 45.00),
(11, 1034, 2, 'Double Fresa', 1, 48.00, 48.00),
(12, 1034, 3, 'Red Velvet', 1, 50.00, 50.00),
(13, 1035, 2, 'Double Fresa', 1, 48.00, 48.00),
(14, 1035, 3, 'Red Velvet', 9, 50.00, 450.00),
(15, 1036, 5, 'Lemon Glass', 8, 45.00, 360.00);

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
(29, 5, 6, 0.010, 'L'),
(30, 1, 1, 0.600, 'kg'),
(31, 1, 2, 0.300, 'kg'),
(32, 1, 3, 0.250, 'kg'),
(33, 1, 4, 0.280, 'kg'),
(34, 1, 5, 2.000, 'pza'),
(35, 1, 6, 0.010, 'L'),
(36, 6, 5, 1.000, 'pz'),
(37, 6, 1, 175.000, 'g'),
(38, 6, 3, 100.000, 'g'),
(39, 6, 2, 100.000, 'g'),
(40, 6, 6, 1.000, 'cuchara');

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
(1, 'Harina de trigo', 20.800, 'kg', 24.00, 10.000, 1, '2026-11-21 02:14:11', '2026-11-25 00:08:35'),
(2, 'Mantequilla sin sal', 1.400, 'kg', 145.00, 5.000, 1, '2026-11-21 02:14:11', '2026-11-25 00:08:35'),
(3, 'Azúcar mascabado', 18.250, 'kg', 12.00, 8.000, 1, '2026-11-21 02:14:11', '2026-11-25 00:08:35'),
(4, 'Chocolate belga', 1.720, 'kg', 220.00, 4.000, 1, '2026-11-21 02:14:11', '2026-11-24 23:59:14'),
(5, 'Huevos frescos', 106.000, 'pza', 3.50, 30.000, 1, '2026-11-21 02:14:11', '2026-11-25 00:08:35'),
(6, 'Esencia de vainilla', 2.430, 'L', 180.00, 1.000, 1, '2026-11-21 02:14:11', '2026-11-25 00:08:35'),
(7, 'Fresa y chocolate blanco', 12.000, 'kg', 200.00, 3.000, 1, '2026-11-21 02:14:11', '2026-11-21 03:32:01'),
(8, 'Cacao y queso crema', 10.000, 'kg', 160.00, 3.000, 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(9, 'Limón y azúcar glass', 6.500, 'kg', 75.00, 2.000, 1, '2026-11-21 02:14:11', '2026-11-25 00:08:35'),
(10, 'Polvo para Hornear ', 102.000, 'kg', 30.00, 2.000, 1, '2026-11-24 23:54:38', '2026-11-24 23:57:11');

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
(1, 1, 22, 10, 343, '2026-11-24 23:59:14'),
(2, 2, 8, 10, 258, '2026-11-21 04:22:45'),
(3, 3, 0, 10, 210, '2026-11-21 04:22:45'),
(4, 4, 10, 10, 165, '2026-11-21 04:15:43'),
(5, 5, 74, 10, 137, '2026-11-25 00:18:06');

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
(1, 3, 'entrada_compra', 2.000, 18.000, 20.000, '3', 'HAZLO YA', '2026-11-20 21:24:51', NULL),
(2, 1, 'salida_produccion', 0.600, 25.000, 24.400, 'BC-LOT-261120213706331980', '', '2026-11-20 21:37:06', NULL),
(3, 2, 'salida_produccion', 0.550, 3.500, 2.950, 'BC-LOT-261120213706331980', '', '2026-11-20 21:37:06', NULL),
(4, 3, 'salida_produccion', 0.250, 20.000, 19.750, 'BC-LOT-261120213706331980', '', '2026-11-20 21:37:06', NULL),
(5, 5, 'salida_produccion', 2.000, 120.000, 118.000, 'BC-LOT-261120213706331980', '', '2026-11-20 21:37:06', NULL),
(6, 6, 'salida_produccion', 0.010, 2.500, 2.490, 'BC-LOT-261120213706331980', '', '2026-11-20 21:37:06', NULL),
(7, 1, 'ajuste_entrada', 0.600, 24.400, 25.000, 'BC-LOT-261120213706331980', 'Reversión de producción', '2026-11-20 21:38:55', NULL),
(8, 2, 'ajuste_entrada', 0.550, 2.950, 3.500, 'BC-LOT-261120213706331980', 'Reversión de producción', '2026-11-20 21:38:56', NULL),
(9, 3, 'ajuste_entrada', 0.250, 19.750, 20.000, 'BC-LOT-261120213706331980', 'Reversión de producción', '2026-11-20 21:38:56', NULL),
(10, 5, 'ajuste_entrada', 2.000, 118.000, 120.000, 'BC-LOT-261120213706331980', 'Reversión de producción', '2026-11-20 21:38:56', NULL),
(11, 6, 'ajuste_entrada', 0.010, 2.490, 2.500, 'BC-LOT-261120213706331980', 'Reversión de producción', '2026-11-20 21:38:56', NULL),
(12, 10, 'entrada_compra', 100.000, 1.000, 101.000, '4', '', '2026-11-24 17:55:38', NULL),
(13, 10, 'entrada_compra', 1.000, 101.000, 102.000, '5', '', '2026-11-24 17:57:11', NULL),
(14, 1, 'salida_produccion', 0.600, 25.000, 24.400, 'BC-LOT-261124175914143617', '', '2026-11-24 17:59:14', NULL),
(15, 2, 'salida_produccion', 0.300, 3.500, 3.200, 'BC-LOT-261124175914143617', '', '2026-11-24 17:59:14', NULL),
(16, 3, 'salida_produccion', 0.250, 20.000, 19.750, 'BC-LOT-261124175914143617', '', '2026-11-24 17:59:14', NULL),
(17, 4, 'salida_produccion', 0.280, 2.000, 1.720, 'BC-LOT-261124175914143617', '', '2026-11-24 17:59:14', NULL),
(18, 5, 'salida_produccion', 2.000, 120.000, 118.000, 'BC-LOT-261124175914143617', '', '2026-11-24 17:59:14', NULL),
(19, 6, 'salida_produccion', 0.010, 2.500, 2.490, 'BC-LOT-261124175914143617', '', '2026-11-24 17:59:14', NULL),
(20, 1, 'salida_produccion', 1.200, 24.400, 23.200, 'BC-LOT-261124180606733846', '', '2026-11-24 18:06:06', NULL),
(21, 2, 'salida_produccion', 0.600, 3.200, 2.600, 'BC-LOT-261124180606733846', '', '2026-11-24 18:06:06', NULL),
(22, 3, 'salida_produccion', 0.500, 19.750, 19.250, 'BC-LOT-261124180606733846', '', '2026-11-24 18:06:06', NULL),
(23, 5, 'salida_produccion', 4.000, 118.000, 114.000, 'BC-LOT-261124180606733846', '', '2026-11-24 18:06:06', NULL),
(24, 6, 'salida_produccion', 0.020, 2.490, 2.470, 'BC-LOT-261124180606733846', '', '2026-11-24 18:06:06', NULL),
(25, 9, 'salida_produccion', 0.500, 8.000, 7.500, 'BC-LOT-261124180606733846', '', '2026-11-24 18:06:06', NULL),
(26, 1, 'salida_produccion', 0.600, 23.200, 22.600, 'BC-LOT-261124180651769844', 'TODO BUENO', '2026-11-24 18:06:51', NULL),
(27, 2, 'salida_produccion', 0.300, 2.600, 2.300, 'BC-LOT-261124180651769844', 'TODO BUENO', '2026-11-24 18:06:51', NULL),
(28, 3, 'salida_produccion', 0.250, 19.250, 19.000, 'BC-LOT-261124180651769844', 'TODO BUENO', '2026-11-24 18:06:51', NULL),
(29, 5, 'salida_produccion', 2.000, 114.000, 112.000, 'BC-LOT-261124180651769844', 'TODO BUENO', '2026-11-24 18:06:51', NULL),
(30, 6, 'salida_produccion', 0.010, 2.470, 2.460, 'BC-LOT-261124180651769844', 'TODO BUENO', '2026-11-24 18:06:51', NULL),
(31, 9, 'salida_produccion', 0.250, 7.500, 7.250, 'BC-LOT-261124180651769844', 'TODO BUENO', '2026-11-24 18:06:51', NULL),
(32, 1, 'salida_produccion', 1.800, 22.600, 20.800, 'BC-LOT-261124180835896524', '', '2026-11-24 18:08:35', NULL),
(33, 2, 'salida_produccion', 0.900, 2.300, 1.400, 'BC-LOT-261124180835896524', '', '2026-11-24 18:08:35', NULL),
(34, 3, 'salida_produccion', 0.750, 19.000, 18.250, 'BC-LOT-261124180835896524', '', '2026-11-24 18:08:35', NULL),
(35, 5, 'salida_produccion', 6.000, 112.000, 106.000, 'BC-LOT-261124180835896524', '', '2026-11-24 18:08:35', NULL),
(36, 6, 'salida_produccion', 0.030, 2.460, 2.430, 'BC-LOT-261124180835896524', '', '2026-11-24 18:08:35', NULL),
(37, 9, 'salida_produccion', 0.750, 7.250, 6.500, 'BC-LOT-261124180835896524', '', '2026-11-24 18:08:35', NULL);

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
(1, 1, 'salida_venta', 1, 128, 127, 'BC-261120212115', NULL, '2026-11-20 21:21:15', NULL),
(2, 3, 'salida_venta', 1, 64, 63, 'BC-261120212115', NULL, '2026-11-20 21:21:15', NULL),
(3, 4, 'salida_venta', 1, 24, 23, 'BC-261120212115', NULL, '2026-11-20 21:21:15', NULL),
(4, 5, 'salida_venta', 2, 52, 50, 'BC-261120212115', NULL, '2026-11-20 21:21:15', NULL),
(5, 1, 'ajuste_salida', 7, 127, 120, NULL, 'Ajuste manual desde inventario', '2026-11-20 21:27:56', NULL),
(6, 2, 'ajuste_salida', 36, 86, 50, NULL, 'Ajuste manual desde inventario', '2026-11-20 21:28:16', NULL),
(7, 1, 'ajuste_salida', 119, 120, 1, NULL, 'Ajuste manual desde inventario', '2026-11-20 21:29:14', NULL),
(8, 2, 'ajuste_salida', 49, 50, 1, NULL, 'Ajuste manual desde inventario', '2026-11-20 21:29:25', NULL),
(9, 3, 'ajuste_salida', 62, 63, 1, NULL, 'Ajuste manual desde inventario', '2026-11-20 21:29:39', NULL),
(10, 4, 'ajuste_salida', 22, 23, 1, NULL, 'Ajuste manual desde inventario', '2026-11-20 21:30:04', NULL),
(11, 5, 'ajuste_salida', 49, 50, 1, NULL, 'Ajuste manual desde inventario', '2026-11-20 21:30:17', NULL),
(12, 4, 'entrada_produccion', 12, 1, 13, 'BC-LOT-261120213706331980', '', '2026-11-20 21:37:06', NULL),
(13, 4, 'ajuste_salida', 12, 13, 1, 'BC-LOT-261120213706331980', 'Reversión de producción', '2026-11-20 21:38:55', NULL),
(14, 3, 'salida_venta', 1, 1, 0, 'BC-261120215325', NULL, '2026-11-20 21:53:25', NULL),
(15, 5, 'salida_venta', 1, 1, 0, 'BC-261120215325', NULL, '2026-11-20 21:53:25', NULL),
(16, 2, 'salida_venta', 1, 10, 9, 'BC-261120221604', NULL, '2026-11-20 22:16:05', NULL),
(17, 3, 'salida_venta', 1, 10, 9, 'BC-261120221604', NULL, '2026-11-20 22:16:05', NULL),
(18, 2, 'salida_venta', 1, 9, 8, 'BC-261120222245', NULL, '2026-11-20 22:22:45', NULL),
(19, 3, 'salida_venta', 9, 9, 0, 'BC-261120222245', NULL, '2026-11-20 22:22:45', NULL),
(20, 1, 'entrada_produccion', 12, 10, 22, 'BC-LOT-261124175914143617', '', '2026-11-24 17:59:14', NULL),
(21, 5, 'entrada_produccion', 24, 10, 34, 'BC-LOT-261124180606733846', '', '2026-11-24 18:06:06', NULL),
(22, 5, 'entrada_produccion', 12, 34, 46, 'BC-LOT-261124180651769844', 'TODO BUENO', '2026-11-24 18:06:51', NULL),
(23, 5, 'entrada_produccion', 36, 46, 82, 'BC-LOT-261124180835896524', '', '2026-11-24 18:08:35', NULL),
(24, 5, 'salida_venta', 8, 82, 74, 'BC-261124181806', NULL, '2026-11-24 18:18:06', NULL);

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
  `metodo_pago` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'efectivo',
  `es_demo` tinyint(1) NOT NULL DEFAULT '0',
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ;

--
-- Dumping data for table `pedidos`
--

INSERT INTO `pedidos` (`id_pedido`, `codigo_pedido`, `id_cliente`, `nombre_cliente`, `correo_cliente`, `telefono_cliente`, `direccion_entrega`, `fecha_pedido`, `subtotal`, `costo_envio`, `descuento`, `total`, `estado`, `mensaje_regalo`, `es_demo`, `creado_en`, `actualizado_en`) VALUES
(1025, 'BC-1025', 4, 'Luis Hernández', NULL, NULL, NULL, '2026-11-20 19:49:11', 300.00, 0.00, 0.00, 300.00, 'completado', NULL, 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(1026, 'BC-1026', 3, 'Ana Martínez', NULL, NULL, NULL, '2026-11-20 19:56:11', 192.00, 0.00, 0.00, 192.00, 'pendiente', NULL, 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(1027, 'BC-1027', 2, 'Carlos Mendoza', NULL, NULL, NULL, '2026-11-20 20:02:11', 540.00, 0.00, 0.00, 540.00, 'en_preparacion', NULL, 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(1028, 'BC-1028', 1, 'María García', NULL, NULL, NULL, '2026-11-20 20:09:11', 270.00, 0.00, 0.00, 270.00, 'completado', NULL, 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(1029, 'BC-261120212115', 5, 'Asael Santiago', 'sasael480@gmail.com', '+524426805849', 'CALLE HEROES DE IGUALA 110', '2026-11-20 21:21:15', 223.00, 0.00, 0.00, 223.00, 'en_preparacion', 'NADAAAAAAAAA', 0, '2026-11-21 03:21:15', '2026-11-21 03:39:20'),
(1030, 'BC-261120215325', NULL, 'Santiago Francisco', 'sasael480@gmail.com', '+524426805849', 'CALLE HEROES DE IGUALA 110', '2026-11-20 21:53:25', 95.00, 0.00, 0.00, 95.00, 'completado', 'DDDDDDD', 0, '2026-11-21 03:53:25', '2026-11-21 04:23:34'),
(1034, 'BC-261120221604', NULL, 'Santiago FranciscoW', NULL, '+524426805849', 'CALLE HEROES DE IGUALA 110', '2026-11-20 22:16:05', 98.00, 0.00, 0.00, 98.00, 'completado', 'WWWWWWWWWWWWWWWWWWWWWWWWWWW', 0, '2026-11-21 04:16:05', '2026-11-21 04:23:29'),
(1035, 'BC-261120222245', 5, 'Asael Santiago', 'sasael480@gmail.com', '+524426805849', '', '2026-11-20 22:22:45', 498.00, 0.00, 0.00, 498.00, 'completado', 'wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww', 0, '2026-11-21 04:22:45', '2026-11-21 04:23:20'),
(1036, 'BC-261124181806', 6, 'Mary', 'mary@gmail.com', '4776655447', 'CALLE HEROES DE IGUALA 110', '2026-11-24 18:18:06', 360.00, 0.00, 0.00, 360.00, 'en_preparacion', 'Gracias por ser mi amigo', 0, '2026-11-25 00:18:06', '2026-11-25 00:19:25');

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
(1, 'BC-LOT-261120213706331980', 4, 4, 1, 12, '2026-11-20 21:37:06', 'cancelada', '', NULL, '2026-11-21 03:37:06'),
(2, 'BC-LOT-261124175914143617', 1, 1, 1, 12, '2026-11-24 17:59:14', 'completada', '', NULL, '2026-11-24 23:59:14'),
(3, 'BC-LOT-261124180606733846', 5, 5, 2, 24, '2026-11-24 18:06:06', 'completada', '', NULL, '2026-11-25 00:06:06'),
(4, 'BC-LOT-261124180651769844', 5, 5, 1, 12, '2026-11-24 18:06:51', 'completada', 'TODO BUENO', NULL, '2026-11-25 00:06:51'),
(5, 'BC-LOT-261124180835896524', 5, 5, 3, 36, '2026-11-24 18:08:35', 'completada', '', NULL, '2026-11-25 00:08:35');

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
(1, 'Bubble Choco', 'Nuestra clásica galleta con generosos trozos de chocolate belga.', 45.00, '/assets/bubblecookies/cookies/bubble-choco.png', '#8cc0eb', 'La favorita', 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(2, 'Double Fresa', 'Doble dosis de fresa y chocolate blanco. Amor a primera mordida.', 48.00, '/assets/bubblecookies/cookies/double-fresa.png', '#efbaca', 'Dulce y especial', 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(3, 'Red Velvet', 'Suave cacao rojo con un corazón cremoso de queso.', 50.00, '/assets/bubblecookies/cookies/red-velvet.png', '#ba8f91', 'Irresistible', 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(4, 'Butter Cookies', 'Mantequilla de verdad, bordes doraditos y mucho cariño.', 38.00, '/assets/bubblecookies/cookies/butter-cookies.png', '#e9d39d', 'Un clásico', 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(5, 'Lemon Glass', 'Un toque de limón fresco bajo un delicado glaseado artesanal.', 45.00, '/assets/bubblecookies/cookies/lemon-glass.png', '#bfc7a3', 'Un toque fresco', 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(6, 'Arcoiris', 'Rica galleta llena de colores y explosion de sabores ', 40.00, '/assets/bubblecookies/cookies/colores.png', '#805D49', 'Colores', 1, '2026-11-24 23:44:16', '2026-11-24 23:45:28');

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
(1, 'Molinos del Valle', '4499494944', '4426805849', 'sasael480@gmail.com', NULL, 1, '2026-11-21 02:14:11'),
(2, 'Lácteos La Pradera', NULL, NULL, NULL, NULL, 0, '2026-11-21 02:14:11'),
(3, 'Asael', 'CONTACTO', '4426805849', 'sasael482@gmail.com', NULL, 1, '2026-11-21 03:26:03'),
(4, 'Ganel y tiendas de reposteria ', 'Numero', '4776899008', 'tienda@gmail.com', NULL, 1, '2026-11-24 23:53:22');

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
(1, 1, 'Receta Bubble Choco', 12, 'Receta inicial de demostración migrada desde BUBBLE.zip.', 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(2, 2, 'Receta Double Fresa', 12, 'Receta inicial de demostración migrada desde BUBBLE.zip.', 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(3, 3, 'Receta Red Velvet', 12, 'Receta inicial de demostración migrada desde BUBBLE.zip.', 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(4, 4, 'Receta Butter Cookies', 12, 'Receta inicial de demostración migrada desde BUBBLE.zip.', 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(5, 5, 'Receta Lemon Glass', 12, 'Receta inicial de demostración migrada desde BUBBLE.zip.', 1, '2026-11-21 02:14:11', '2026-11-21 02:14:11'),
(6, 6, 'Receta Arcoiris', 12, 'Debes mezclar todo con las manos y hornear a 180 grados ', 1, '2026-11-24 23:50:10', '2026-11-24 23:50:10');

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
  MODIFY `id_campania` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `carritos`
--
ALTER TABLE `carritos`
  MODIFY `id_carrito` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id_cliente` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

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
  MODIFY `id_movimiento` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `movimientos_producto_terminado`
--
ALTER TABLE `movimientos_producto_terminado`
  MODIFY `id_movimiento` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

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
  MODIFY `id_proveedor` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `recetas`
--
ALTER TABLE `recetas`
  MODIFY `id_receta` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

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
