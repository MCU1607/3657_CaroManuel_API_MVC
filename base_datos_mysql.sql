-- =====================================================================
-- PROYECTO GAMEZONE - CONVERSIÓN DE SQL SERVER A MYSQL
-- Compatible con MySQL 8.0+
-- Ejecutar el script completo en MySQL Workbench.
-- =====================================================================

/* =====================================================================
   PROCESO DE APRENDIZAJE 3 - Programación web básica (2026-20)
   Proyecto : GameZone - Tienda web de consolas y videojuegos
   Motor    : Microsoft SQL Server
   Estudiante: Caro Ulloa, Manuel Armando   |   NRC: 3657
   Contenido : BD, tablas, PK/FK, restricciones, índices, vista,
               procedimientos almacenados y datos de prueba
   ===================================================================== */


/* ---------------------------------------------------------------------
   1. CREACIÓN DE LA BASE DE DATOS (desde cero)
   --------------------------------------------------------------------- */


DROP DATABASE IF EXISTS GameZoneDB;
CREATE DATABASE GameZoneDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE GameZoneDB;

/* ---------------------------------------------------------------------
   2. CREACIÓN DE TABLAS
   --------------------------------------------------------------------- */

-- 2.1 Categorías 
CREATE TABLE Categoria (
    IdCategoria  INT AUTO_INCREMENT NOT NULL,
    Nombre       VARCHAR(60)      NOT NULL,
    Descripcion  VARCHAR(200)     NULL,
    CONSTRAINT PK_Categoria        PRIMARY KEY (IdCategoria),
    CONSTRAINT UQ_Categoria_Nombre UNIQUE (Nombre)
);

-- 2.2 Plataformas 
CREATE TABLE Plataforma (
    IdPlataforma INT AUTO_INCREMENT NOT NULL,
    Nombre       VARCHAR(60)      NOT NULL,
    Fabricante   VARCHAR(60)      NOT NULL,
    CONSTRAINT PK_Plataforma        PRIMARY KEY (IdPlataforma),
    CONSTRAINT UQ_Plataforma_Nombre UNIQUE (Nombre)
);

-- 2.3 Productos 
CREATE TABLE Producto (
    IdProducto    INT AUTO_INCREMENT NOT NULL,
    IdCategoria   INT               NOT NULL,
    IdPlataforma  INT               NOT NULL,
    Nombre        VARCHAR(120)     NOT NULL,
    Tipo          VARCHAR(20)      NOT NULL,
    Descripcion   VARCHAR(500)     NULL,
    Precio        DECIMAL(10,2)     NOT NULL, 
    Stock         INT               NOT NULL DEFAULT 0,
    ImagenUrl     VARCHAR(255)     NULL,
    Destacado     TINYINT(1)               NOT NULL DEFAULT 0,
    Activo        TINYINT(1)               NOT NULL DEFAULT 1,
    FechaRegistro DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Producto           PRIMARY KEY (IdProducto),
    CONSTRAINT FK_Producto_Categoria FOREIGN KEY (IdCategoria)  REFERENCES Categoria (IdCategoria),
    CONSTRAINT FK_Producto_Plataforma FOREIGN KEY (IdPlataforma) REFERENCES Plataforma (IdPlataforma),
    CONSTRAINT CK_Producto_Tipo      CHECK (Tipo IN ('Consola', 'Videojuego', 'Accesorio')),
    CONSTRAINT CK_Producto_Precio    CHECK (Precio > 0),
    CONSTRAINT CK_Producto_Stock     CHECK (Stock >= 0)
);

-- 2.4 Clientes
CREATE TABLE Cliente (
    IdCliente     INT AUTO_INCREMENT NOT NULL,
    Dni           CHAR(8)           NOT NULL,
    Nombres       VARCHAR(80)      NOT NULL,
    Apellidos     VARCHAR(80)      NOT NULL,
    Correo        VARCHAR(100)     NOT NULL,
    Telefono      CHAR(9)           NOT NULL,
    Direccion     VARCHAR(150)     NULL,
    Distrito      VARCHAR(60)      NULL,
    Departamento  VARCHAR(60)      NOT NULL DEFAULT ('Lima'),
    FechaRegistro DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Activo        TINYINT(1)               NOT NULL DEFAULT 1,
    CONSTRAINT PK_Cliente        PRIMARY KEY (IdCliente),
    CONSTRAINT UQ_Cliente_Dni    UNIQUE (Dni),
    CONSTRAINT UQ_Cliente_Correo UNIQUE (Correo),
    CONSTRAINT CK_Cliente_Dni    CHECK (Dni REGEXP '^[0-9]{8}$'),
    CONSTRAINT CK_Cliente_Correo CHECK (Correo REGEXP '^[^@ ]+@[^@ ]+\\.[^@ ]+$'),
    CONSTRAINT CK_Cliente_Tel    CHECK (Telefono REGEXP '^9[0-9]{8}$')
);

-- 2.5 Usuarios del panel de administración
CREATE TABLE UsuarioAdmin (
    IdUsuario     INT AUTO_INCREMENT NOT NULL,
    Nombres       VARCHAR(100)     NOT NULL,
    Correo        VARCHAR(100)     NOT NULL,
    ClaveHash     BINARY(32)     NOT NULL,   -- SHA-256 (en PHP puede usarse password_hash)
    Rol           VARCHAR(20)      NOT NULL,
    Activo        TINYINT(1)               NOT NULL DEFAULT 1,
    FechaCreacion DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_UsuarioAdmin        PRIMARY KEY (IdUsuario),
    CONSTRAINT UQ_UsuarioAdmin_Correo UNIQUE (Correo),
    CONSTRAINT CK_UsuarioAdmin_Rol    CHECK (Rol IN ('Administrador', 'Vendedor', 'Almacen'))
);

-- 2.6 Pedidos (cabecera)
CREATE TABLE Pedido (
    IdPedido         INT AUTO_INCREMENT NOT NULL,
    IdCliente        INT               NOT NULL,
    IdUsuario        INT               NULL,      -- vendedor que atiende
    FechaPedido      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Estado           VARCHAR(20)      NOT NULL DEFAULT ('Pendiente'),
    MetodoPago       VARCHAR(20)      NOT NULL,
    TipoEntrega      VARCHAR(20)      NOT NULL,
    DireccionEntrega VARCHAR(150)     NULL,
    Total            DECIMAL(10,2)     NOT NULL DEFAULT 0,
    CONSTRAINT PK_Pedido         PRIMARY KEY (IdPedido),
    CONSTRAINT FK_Pedido_Cliente FOREIGN KEY (IdCliente) REFERENCES Cliente (IdCliente),
    CONSTRAINT FK_Pedido_Usuario FOREIGN KEY (IdUsuario) REFERENCES UsuarioAdmin (IdUsuario),
    CONSTRAINT CK_Pedido_Estado  CHECK (Estado IN ('Pendiente', 'Pagado', 'Enviado', 'Entregado', 'Cancelado')),
    CONSTRAINT CK_Pedido_Pago    CHECK (MetodoPago IN ('Efectivo', 'Tarjeta', 'Yape', 'Plin', 'Transferencia')),
    CONSTRAINT CK_Pedido_Entrega CHECK (TipoEntrega IN ('Recojo en tienda', 'Delivery')),
    CONSTRAINT CK_Pedido_Direccion CHECK (TipoEntrega <> 'Delivery' OR DireccionEntrega IS NOT NULL),
    CONSTRAINT CK_Pedido_Total   CHECK (Total >= 0)
);

-- 2.7 Detalle de pedido (productos de cada pedido)
CREATE TABLE DetallePedido (
    IdDetalle      INT AUTO_INCREMENT NOT NULL,
    IdPedido       INT               NOT NULL,
    IdProducto     INT               NOT NULL,
    Cantidad       INT               NOT NULL,
    PrecioUnitario DECIMAL(10,2)     NOT NULL,
    Subtotal       DECIMAL(12,2) GENERATED ALWAYS AS (Cantidad * PrecioUnitario) STORED,
    CONSTRAINT PK_DetallePedido          PRIMARY KEY (IdDetalle),
    CONSTRAINT FK_Detalle_Pedido         FOREIGN KEY (IdPedido)   REFERENCES Pedido (IdPedido) ON DELETE CASCADE,
    CONSTRAINT FK_Detalle_Producto       FOREIGN KEY (IdProducto) REFERENCES Producto (IdProducto),
    CONSTRAINT UQ_Detalle_Pedido_Producto UNIQUE (IdPedido, IdProducto),
    CONSTRAINT CK_Detalle_Cantidad       CHECK (Cantidad > 0),
    CONSTRAINT CK_Detalle_Precio         CHECK (PrecioUnitario >= 0)
);

-- 2.8 Servicios que ofrece la tienda
CREATE TABLE Servicio (
    IdServicio        INT AUTO_INCREMENT NOT NULL,
    Nombre            VARCHAR(80)      NOT NULL,
    Descripcion       VARCHAR(300)     NULL,
    PrecioReferencial DECIMAL(10,2)     NULL,
    Activo            TINYINT(1)               NOT NULL DEFAULT 1,
    CONSTRAINT PK_Servicio        PRIMARY KEY (IdServicio),
    CONSTRAINT UQ_Servicio_Nombre UNIQUE (Nombre),
    CONSTRAINT CK_Servicio_Precio CHECK (PrecioReferencial IS NULL OR PrecioReferencial >= 0)
);

-- 2.9 Solicitudes de servicio (asesoría, garantía, soporte, entrega)
CREATE TABLE SolicitudServicio (
    IdSolicitud    INT AUTO_INCREMENT NOT NULL,
    IdCliente      INT               NOT NULL,
    IdServicio     INT               NOT NULL,
    IdPedido       INT               NULL,      -- pedido relacionado (si aplica)
    FechaSolicitud DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Estado         VARCHAR(20)      NOT NULL DEFAULT ('Recibida'),
    Detalle        VARCHAR(300)     NULL,
    CONSTRAINT PK_SolicitudServicio  PRIMARY KEY (IdSolicitud),
    CONSTRAINT FK_Solicitud_Cliente  FOREIGN KEY (IdCliente)  REFERENCES Cliente (IdCliente),
    CONSTRAINT FK_Solicitud_Servicio FOREIGN KEY (IdServicio) REFERENCES Servicio (IdServicio),
    CONSTRAINT FK_Solicitud_Pedido   FOREIGN KEY (IdPedido)   REFERENCES Pedido (IdPedido),
    CONSTRAINT CK_Solicitud_Estado   CHECK (Estado IN ('Recibida', 'En proceso', 'Atendida', 'Cerrada'))
);

-- 2.10 Consultas del formulario de contacto
CREATE TABLE ContactoConsulta (
    IdConsulta  INT AUTO_INCREMENT NOT NULL,
    IdCliente   INT               NULL,     
    Nombre      VARCHAR(100)     NOT NULL,
    Correo      VARCHAR(100)     NOT NULL,
    Telefono    CHAR(9)           NULL,
    Asunto      VARCHAR(100)     NOT NULL,
    Mensaje     VARCHAR(500)     NOT NULL,
    FechaEnvio  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Atendida    TINYINT(1)               NOT NULL DEFAULT 0,
    CONSTRAINT PK_ContactoConsulta PRIMARY KEY (IdConsulta),
    CONSTRAINT FK_Consulta_Cliente FOREIGN KEY (IdCliente) REFERENCES Cliente (IdCliente),
    CONSTRAINT CK_Consulta_Correo  CHECK (Correo REGEXP '^[^@ ]+@[^@ ]+\\.[^@ ]+$'),
    CONSTRAINT CK_Consulta_Tel     CHECK (Telefono IS NULL OR Telefono REGEXP '^9[0-9]{8}$')
);

/* ---------------------------------------------------------------------
   3. ÍNDICES (búsqueda, filtros y uniones frecuentes)
   --------------------------------------------------------------------- */
CREATE INDEX IX_Producto_IdCategoria  ON Producto (IdCategoria);
CREATE INDEX IX_Producto_IdPlataforma ON Producto (IdPlataforma);
CREATE INDEX IX_Producto_Nombre       ON Producto (Nombre);
CREATE INDEX IX_Producto_Destacados ON Producto (Destacado, Activo, Precio);
CREATE INDEX IX_Pedido_IdCliente      ON Pedido (IdCliente);
CREATE INDEX IX_Pedido_FechaPedido    ON Pedido (FechaPedido);
CREATE INDEX IX_Detalle_IdProducto    ON DetallePedido (IdProducto);
CREATE INDEX IX_Solicitud_IdCliente   ON SolicitudServicio (IdCliente);
CREATE INDEX IX_Solicitud_Estado      ON SolicitudServicio (Estado);

/* ---------------------------------------------------------------------
   4. DATOS DE PRUEBA
   --------------------------------------------------------------------- */

-- Categorías
INSERT INTO Categoria (Nombre, Descripcion) VALUES
('Acción y aventura', 'Juegos de acción, exploración y aventura'),
('Deportes',          'Fútbol y otros deportes'),
('Carreras',          'Juegos de conducción y velocidad'),
('Familiar',          'Juegos para todas las edades'),
('Consolas',          'Consolas de videojuegos'),
('Accesorios',        'Controles y complementos');

-- Plataformas
INSERT INTO Plataforma (Nombre, Fabricante) VALUES
('PlayStation 5',      'Sony'),
('Xbox Series X|S',    'Microsoft'),
('Nintendo Switch',    'Nintendo');

-- Productos
INSERT INTO Producto (IdCategoria, IdPlataforma, Nombre, Tipo, Descripcion, Precio, Stock, ImagenUrl, Destacado) VALUES
(5, 1, 'PlayStation 5 Slim Edición Disco 1TB', 'Consola',    'Consola de nueva generación con lector de discos y SSD de 1TB.', 2399.00,  8, 'img/productos/ps5-slim.jpg',        1),
(5, 2, 'Xbox Series X 1TB',                    'Consola',    'Consola de Microsoft con juego en 4K y SSD de 1TB.',             2499.00,  5, 'img/productos/xbox-series-x.jpg',    1),
(5, 3, 'Nintendo Switch OLED 64GB',            'Consola',    'Consola híbrida con pantalla OLED de 7 pulgadas.',               1399.00, 12, 'img/productos/switch-oled.jpg',      1),
(5, 2, 'Xbox Series S 512GB',                  'Consola',    'Consola digital compacta, sin lector de discos.',                1199.00,  6, 'img/productos/xbox-series-s.jpg',    0),
(2, 1, 'EA Sports FC 26',                      'Videojuego', 'Simulador de fútbol con ligas y clubes oficiales.',               249.00, 20, 'img/productos/fc26-ps5.jpg',          1),
(1, 1, 'God of War Ragnarök',                  'Videojuego', 'Aventura de acción basada en la mitología nórdica.',              199.00, 15, 'img/productos/gow-ragnarok.jpg',      0),
(4, 3, 'Mario Kart 8 Deluxe',                  'Videojuego', 'Carreras para toda la familia, hasta 4 jugadores.',               259.00, 14, 'img/productos/mario-kart-8.jpg',      1),
(1, 3, 'The Legend of Zelda: Tears of the Kingdom', 'Videojuego', 'Aventura de mundo abierto en Hyrule.',                       279.00, 10, 'img/productos/zelda-totk.jpg',        1),
(3, 2, 'Forza Horizon 5',                      'Videojuego', 'Carreras de mundo abierto con autos de todo tipo.',               219.00,  9, 'img/productos/forza-horizon-5.jpg',   0),
(6, 1, 'Control inalámbrico DualSense',        'Accesorio',  'Control con respuesta háptica y gatillos adaptativos.',           299.00, 18, 'img/productos/dualsense.jpg',         0);

-- Clientes
INSERT INTO Cliente (Dni, Nombres, Apellidos, Correo, Telefono, Direccion, Distrito, Departamento) VALUES
('45872316', 'Luis Alberto',     'Quispe Mamani',    'luis.quispe@gmail.com',     '987654321', 'Av. Petit Thouars 3540',  'San Isidro',        'Lima'),
('70234581', 'María Fernanda',   'Torres Ríos',      'mf.torres@outlook.com',     '986123457', 'Av. Larco 812',           'Miraflores',        'Lima'),
('41893267', 'Carlos Eduardo',   'Huamán Flores',    'carlos.huaman@gmail.com',   '945321876', 'Jr. de la Unión 455',     'Cercado de Lima',   'Lima'),
('72618945', 'Rosa Elena',       'Vásquez Chávez',   'rosa.vasquez@hotmail.com',  '912456789', 'Av. Universitaria 1840',  'Los Olivos',        'Lima'),
('46127389', 'Jorge Luis',       'Mendoza Paredes',  'jorge.mendoza@gmail.com',   '984765432', 'Av. El Sol 345',          'Cusco',             'Cusco'),
('43975218', 'Ana Lucía',        'Cárdenas Rojas',   'ana.cardenas@gmail.com',    '958234167', 'Calle Mercaderes 210',    'Arequipa',          'Arequipa'),
('71846392', 'Diego Alonso',     'Ramírez Salazar',  'diego.ramirez@gmail.com',   '973681524', 'Av. La Marina 2355',      'San Miguel',        'Lima'),
('40368125', 'Patricia Milagros','Gutiérrez León',   'patricia.gutierrez@gmail.com','996125478', 'Av. Benavides 4120',    'Santiago de Surco', 'Lima'),
('47291836', 'Miguel Ángel',     'Rojas Campos',     'miguel.rojas@outlook.com',  '947852136', 'Av. España 1450',         'Trujillo',          'La Libertad'),
('73518264', 'Sofía Valeria',    'Delgado Ponce',    'sofia.delgado@gmail.com',   '961357842', 'Av. Grau 540',            'Piura',             'Piura');

-- Usuarios del panel de administración
-- Contraseñas de práctica: Admin2026!, Ventas2026!, Almacen2026! (se guardan solo como hash)
INSERT INTO UsuarioAdmin (Nombres, Correo, ClaveHash, Rol) VALUES
('Manuel Armando Caro Ulloa', 'admin@gamezone.pe',   UNHEX(SHA2('Admin2026!', 256)),   'Administrador'),
('Daniela Paredes Ruiz',      'ventas@gamezone.pe',  UNHEX(SHA2('Ventas2026!', 256)),  'Vendedor'),
('Renzo Castillo Vargas',     'almacen@gamezone.pe', UNHEX(SHA2('Almacen2026!', 256)), 'Almacen');

-- Pedidos
INSERT INTO Pedido (IdCliente, IdUsuario, FechaPedido, Estado, MetodoPago, TipoEntrega, DireccionEntrega) VALUES
(1, 2, '2026-10-03T11:20:00', 'Entregado', 'Yape',          'Delivery',         'Av. Petit Thouars 3540, San Isidro, Lima'),
(2, 2, '2026-10-07T16:45:00', 'Entregado', 'Tarjeta',       'Recojo en tienda', NULL),
(3, 2, '2026-10-12T10:05:00', 'Entregado', 'Efectivo',      'Recojo en tienda', NULL),
(5, 2, '2026-10-18T19:30:00', 'Enviado',   'Transferencia', 'Delivery',         'Av. El Sol 345, Cusco'),
(8, 2, '2026-10-24T13:15:00', 'Pagado',    'Plin',          'Delivery',         'Av. Benavides 4120, Santiago de Surco, Lima'),
(6, 2, '2026-10-29T09:40:00', 'Pendiente', 'Yape',          'Delivery',         'Calle Mercaderes 210, Arequipa');

-- Detalle de pedidos
INSERT INTO DetallePedido (IdPedido, IdProducto, Cantidad, PrecioUnitario) VALUES
(1,  1, 1, 2399.00),
(1, 10, 1,  299.00),
(2,  3, 1, 1399.00),
(2,  7, 1,  259.00),
(3,  5, 2,  249.00),
(3,  6, 1,  199.00),
(4,  2, 1, 2499.00),
(4,  9, 1,  219.00),
(5,  8, 1,  279.00),
(6,  4, 1, 1199.00);

-- Cálculo del total de cada pedido a partir de su detalle
UPDATE Pedido p
INNER JOIN (
    SELECT IdPedido, SUM(Subtotal) AS TotalPedido
    FROM DetallePedido
    GROUP BY IdPedido
) d ON d.IdPedido = p.IdPedido
SET p.Total = d.TotalPedido;

-- Servicios
INSERT INTO Servicio (Nombre, Descripcion, PrecioReferencial) VALUES
('Venta de consolas y videojuegos', 'Venta de productos nuevos con comprobante de pago.',            NULL),
('Asesoría personalizada',          'Recomendación de consola o juegos según edad y presupuesto.',    0.00),
('Garantía de productos',           'Garantía de 12 meses por defectos de fábrica en consolas.',      NULL),
('Soporte técnico',                 'Diagnóstico y reparación básica de consolas y controles.',      80.00),
('Entrega a domicilio',             'Delivery en Lima Metropolitana y envíos a provincias.',         15.00);

-- Solicitudes de servicio 
INSERT INTO SolicitudServicio (IdCliente, IdServicio, IdPedido, FechaSolicitud, Estado, Detalle) VALUES
(1, 5, 1,    '2026-10-03T11:25:00', 'Atendida',   'Entrega a domicilio en San Isidro.'),
(2, 2, NULL, '2026-10-06T15:10:00', 'Atendida',   'Consulta sobre qué consola elegir para su hijo.'),
(3, 3, 3,    '2026-10-20T12:00:00', 'En proceso', 'Reclamo de garantía: el disco de God of War no es reconocido.'),
(5, 5, 4,    '2026-10-18T19:35:00', 'En proceso', 'Envío a Cusco mediante agencia de transporte.'),
(7, 4, NULL, '2026-10-25T17:20:00', 'Recibida',   'La consola no enciende, solicita diagnóstico.'),
(8, 2, NULL, '2026-10-22T11:45:00', 'Cerrada',    'Asesoría sobre juegos para Nintendo Switch.');

-- Consultas de contacto (6)
INSERT INTO ContactoConsulta (IdCliente, Nombre, Correo, Telefono, Asunto, Mensaje, FechaEnvio, Atendida) VALUES
(NULL, 'Jimena Alva Soto',   'jimena.alva@hotmail.com',  '955123478', 'Consulta de stock',   '¿Tienen disponible el PlayStation 5 y hacen envíos a Chiclayo?',          '2026-10-02T09:12:00', 1),
(4,    'Rosa Vásquez Chávez','rosa.vasquez@hotmail.com', '912456789', 'Garantía',            'Quisiera saber cuánto dura la garantía de las consolas.',                  '2026-10-09T18:30:00', 1),
(NULL, 'Pedro Salinas Cruz', 'pedro.salinas@gmail.com',  NULL,        'Horario de atención', '¿Atienden los domingos? Quiero recoger un pedido.',                        '2026-10-15T20:05:00', 1),
(NULL, 'Lucero Benites Díaz','lucero.benites@gmail.com', '964782135', 'Juegos para niños',   'Busco un juego para mi hijo de 8 años, ¿qué me recomiendan?',              '2026-10-21T14:40:00', 0),
(9,    'Miguel Rojas Campos','miguel.rojas@outlook.com', '947852136', 'Envío a Trujillo',    '¿Cuánto demora el envío a Trujillo y cuál es el costo?',                   '2026-10-27T10:55:00', 0),
(NULL, 'Andrea Núñez Bravo', 'andrea.nunez@gmail.com',   '938456721', 'Precio al por mayor', 'Necesito cotizar 5 controles DualSense para un torneo de mi universidad.', '2026-10-30T16:20:00', 0);

/* ---------------------------------------------------------------------
   5. VISTA
   --------------------------------------------------------------------- */
SET SQL_SAFE_UPDATES = 1;
CREATE VIEW vw_ResumenPedidos
AS
SELECT  p.IdPedido,
        p.FechaPedido,
        CONCAT(c.Nombres, ' ', c.Apellidos) AS Cliente,
        p.Estado,
        p.MetodoPago,
        p.TipoEntrega,
        p.Total,
        u.Nombres AS Vendedor
FROM    Pedido p
INNER JOIN Cliente c      ON c.IdCliente = p.IdCliente
LEFT  JOIN UsuarioAdmin u ON u.IdUsuario = p.IdUsuario;

/* ---------------------------------------------------------------------
   6. PROCEDIMIENTOS ALMACENADOS
   --------------------------------------------------------------------- */

DELIMITER $$

-- 6.1 Registra la cabecera de un pedido nuevo (estado Pendiente)
CREATE PROCEDURE sp_RegistrarPedido(
    IN p_IdCliente INT,
    IN p_IdUsuario INT,
    IN p_MetodoPago VARCHAR(20),
    IN p_TipoEntrega VARCHAR(20),
    IN p_DireccionEntrega VARCHAR(150),
    OUT p_IdPedido INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Cliente
        WHERE IdCliente = p_IdCliente AND Activo = 1
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El cliente no existe o está inactivo.';
    END IF;

    INSERT INTO Pedido (IdCliente, IdUsuario, MetodoPago, TipoEntrega, DireccionEntrega)
    VALUES (p_IdCliente, p_IdUsuario, p_MetodoPago, p_TipoEntrega, p_DireccionEntrega);

    SET p_IdPedido = LAST_INSERT_ID();
END$$

-- 6.2 Agrega un producto a un pedido pendiente: valida stock, descuenta stock y recalcula el total
CREATE PROCEDURE sp_AgregarDetallePedido(
    IN p_IdPedido INT,
    IN p_IdProducto INT,
    IN p_Cantidad INT
)
BEGIN
    DECLARE v_Estado VARCHAR(20);
    DECLARE v_Precio DECIMAL(10,2);
    DECLARE v_Stock INT;
    DECLARE v_Existe INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT Estado INTO v_Estado
    FROM Pedido
    WHERE IdPedido = p_IdPedido
    FOR UPDATE;

    IF v_Estado IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El pedido no existe.';
    END IF;

    IF v_Estado <> 'Pendiente' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Solo se pueden agregar productos a pedidos pendientes.';
    END IF;

    IF p_Cantidad IS NULL OR p_Cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La cantidad debe ser mayor que cero.';
    END IF;

    SELECT Precio, Stock INTO v_Precio, v_Stock
    FROM Producto
    WHERE IdProducto = p_IdProducto AND Activo = 1
    FOR UPDATE;

    IF v_Precio IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El producto no existe o está inactivo.';
    END IF;

    IF v_Stock < p_Cantidad THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Stock insuficiente para el producto solicitado.';
    END IF;

    SELECT COUNT(*) INTO v_Existe
    FROM DetallePedido
    WHERE IdPedido = p_IdPedido AND IdProducto = p_IdProducto;

    IF v_Existe > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El producto ya fue agregado a este pedido.';
    END IF;

    INSERT INTO DetallePedido (IdPedido, IdProducto, Cantidad, PrecioUnitario)
    VALUES (p_IdPedido, p_IdProducto, p_Cantidad, v_Precio);

    UPDATE Producto
    SET Stock = Stock - p_Cantidad
    WHERE IdProducto = p_IdProducto;

    UPDATE Pedido
    SET Total = (
        SELECT COALESCE(SUM(Subtotal), 0)
        FROM DetallePedido
        WHERE IdPedido = p_IdPedido
    )
    WHERE IdPedido = p_IdPedido;

    COMMIT;
END$$

-- 6.3 Cambia el estado de un pedido; si se cancela, devuelve el stock
CREATE PROCEDURE sp_CambiarEstadoPedido(
    IN p_IdPedido INT,
    IN p_NuevoEstado VARCHAR(20)
)
BEGIN
    DECLARE v_EstadoActual VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT Estado INTO v_EstadoActual
    FROM Pedido
    WHERE IdPedido = p_IdPedido
    FOR UPDATE;

    IF v_EstadoActual IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El pedido no existe.';
    END IF;

    IF v_EstadoActual IN ('Entregado', 'Cancelado') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Un pedido entregado o cancelado ya no puede cambiar de estado.';
    END IF;

    IF p_NuevoEstado = 'Cancelado' THEN
        UPDATE Producto pr
        INNER JOIN DetallePedido d ON d.IdProducto = pr.IdProducto
        SET pr.Stock = pr.Stock + d.Cantidad
        WHERE d.IdPedido = p_IdPedido;
    END IF;

    UPDATE Pedido
    SET Estado = p_NuevoEstado
    WHERE IdPedido = p_IdPedido;

    COMMIT;
END$$

DELIMITER ;

/* ---------------------------------------------------------------------
   7. VERIFICACIÓN: 
   --------------------------------------------------------------------- */
SELECT 'Categoria' AS Tabla, COUNT(*) AS Registros FROM Categoria
UNION ALL SELECT 'Plataforma',        COUNT(*) FROM Plataforma
UNION ALL SELECT 'Producto',          COUNT(*) FROM Producto
UNION ALL SELECT 'Cliente',           COUNT(*) FROM Cliente
UNION ALL SELECT 'UsuarioAdmin',      COUNT(*) FROM UsuarioAdmin
UNION ALL SELECT 'Pedido',            COUNT(*) FROM Pedido
UNION ALL SELECT 'DetallePedido',     COUNT(*) FROM DetallePedido
UNION ALL SELECT 'Servicio',          COUNT(*) FROM Servicio
UNION ALL SELECT 'SolicitudServicio', COUNT(*) FROM SolicitudServicio
UNION ALL SELECT 'ContactoConsulta',  COUNT(*) FROM ContactoConsulta;

