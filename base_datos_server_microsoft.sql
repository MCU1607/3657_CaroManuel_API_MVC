/* =====================================================================
   PROCESO DE APRENDIZAJE 3 - Programación web básica (2026-20)
   Proyecto : GameZone - Tienda web de consolas y videojuegos
   Motor    : Microsoft SQL Server
   Estudiante: Caro Ulloa, Manuel Armando   |   NRC: 3657
   Contenido : BD, tablas, PK/FK, restricciones, índices, vista,
               procedimientos almacenados y datos de prueba
   ===================================================================== */

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/* ---------------------------------------------------------------------
   1. CREACIÓN DE LA BASE DE DATOS (desde cero)
   --------------------------------------------------------------------- */
USE master;
GO

IF DB_ID(N'GameZoneDB') IS NOT NULL
BEGIN
    ALTER DATABASE GameZoneDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GameZoneDB;
END
GO

CREATE DATABASE GameZoneDB;
GO

USE GameZoneDB;
GO

/* ---------------------------------------------------------------------
   2. CREACIÓN DE TABLAS
   --------------------------------------------------------------------- */

-- 2.1 Categorías 
CREATE TABLE dbo.Categoria (
    IdCategoria  INT IDENTITY(1,1) NOT NULL,
    Nombre       NVARCHAR(60)      NOT NULL,
    Descripcion  NVARCHAR(200)     NULL,
    CONSTRAINT PK_Categoria        PRIMARY KEY (IdCategoria),
    CONSTRAINT UQ_Categoria_Nombre UNIQUE (Nombre)
);
GO

-- 2.2 Plataformas 
CREATE TABLE dbo.Plataforma (
    IdPlataforma INT IDENTITY(1,1) NOT NULL,
    Nombre       NVARCHAR(60)      NOT NULL,
    Fabricante   NVARCHAR(60)      NOT NULL,
    CONSTRAINT PK_Plataforma        PRIMARY KEY (IdPlataforma),
    CONSTRAINT UQ_Plataforma_Nombre UNIQUE (Nombre)
);
GO

-- 2.3 Productos 
CREATE TABLE dbo.Producto (
    IdProducto    INT IDENTITY(1,1) NOT NULL,
    IdCategoria   INT               NOT NULL,
    IdPlataforma  INT               NOT NULL,
    Nombre        NVARCHAR(120)     NOT NULL,
    Tipo          NVARCHAR(20)      NOT NULL,
    Descripcion   NVARCHAR(500)     NULL,
    Precio        DECIMAL(10,2)     NOT NULL, 
    Stock         INT               NOT NULL CONSTRAINT DF_Producto_Stock DEFAULT (0),
    ImagenUrl     NVARCHAR(255)     NULL,
    Destacado     BIT               NOT NULL CONSTRAINT DF_Producto_Destacado DEFAULT (0),
    Activo        BIT               NOT NULL CONSTRAINT DF_Producto_Activo DEFAULT (1),
    FechaRegistro DATETIME2(0)      NOT NULL CONSTRAINT DF_Producto_Fecha DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_Producto           PRIMARY KEY (IdProducto),
    CONSTRAINT FK_Producto_Categoria FOREIGN KEY (IdCategoria)  REFERENCES dbo.Categoria (IdCategoria),
    CONSTRAINT FK_Producto_Plataforma FOREIGN KEY (IdPlataforma) REFERENCES dbo.Plataforma (IdPlataforma),
    CONSTRAINT CK_Producto_Tipo      CHECK (Tipo IN (N'Consola', N'Videojuego', N'Accesorio')),
    CONSTRAINT CK_Producto_Precio    CHECK (Precio > 0),
    CONSTRAINT CK_Producto_Stock     CHECK (Stock >= 0)
);
GO

-- 2.4 Clientes
CREATE TABLE dbo.Cliente (
    IdCliente     INT IDENTITY(1,1) NOT NULL,
    Dni           CHAR(8)           NOT NULL,
    Nombres       NVARCHAR(80)      NOT NULL,
    Apellidos     NVARCHAR(80)      NOT NULL,
    Correo        NVARCHAR(100)     NOT NULL,
    Telefono      CHAR(9)           NOT NULL,
    Direccion     NVARCHAR(150)     NULL,
    Distrito      NVARCHAR(60)      NULL,
    Departamento  NVARCHAR(60)      NOT NULL CONSTRAINT DF_Cliente_Depto DEFAULT (N'Lima'),
    FechaRegistro DATETIME2(0)      NOT NULL CONSTRAINT DF_Cliente_Fecha DEFAULT (SYSDATETIME()),
    Activo        BIT               NOT NULL CONSTRAINT DF_Cliente_Activo DEFAULT (1),
    CONSTRAINT PK_Cliente        PRIMARY KEY (IdCliente),
    CONSTRAINT UQ_Cliente_Dni    UNIQUE (Dni),
    CONSTRAINT UQ_Cliente_Correo UNIQUE (Correo),
    CONSTRAINT CK_Cliente_Dni    CHECK (Dni NOT LIKE '%[^0-9]%' AND LEN(Dni) = 8),
    CONSTRAINT CK_Cliente_Correo CHECK (Correo LIKE '%_@_%._%'),
    CONSTRAINT CK_Cliente_Tel    CHECK (Telefono LIKE '9[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);
GO

-- 2.5 Usuarios del panel de administración
CREATE TABLE dbo.UsuarioAdmin (
    IdUsuario     INT IDENTITY(1,1) NOT NULL,
    Nombres       NVARCHAR(100)     NOT NULL,
    Correo        NVARCHAR(100)     NOT NULL,
    ClaveHash     VARBINARY(32)     NOT NULL,   -- SHA-256 (en PHP puede usarse password_hash)
    Rol           NVARCHAR(20)      NOT NULL,
    Activo        BIT               NOT NULL CONSTRAINT DF_Usuario_Activo DEFAULT (1),
    FechaCreacion DATETIME2(0)      NOT NULL CONSTRAINT DF_Usuario_Fecha DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_UsuarioAdmin        PRIMARY KEY (IdUsuario),
    CONSTRAINT UQ_UsuarioAdmin_Correo UNIQUE (Correo),
    CONSTRAINT CK_UsuarioAdmin_Rol    CHECK (Rol IN (N'Administrador', N'Vendedor', N'Almacen'))
);
GO

-- 2.6 Pedidos (cabecera)
CREATE TABLE dbo.Pedido (
    IdPedido         INT IDENTITY(1,1) NOT NULL,
    IdCliente        INT               NOT NULL,
    IdUsuario        INT               NULL,      -- vendedor que atiende
    FechaPedido      DATETIME2(0)      NOT NULL CONSTRAINT DF_Pedido_Fecha DEFAULT (SYSDATETIME()),
    Estado           NVARCHAR(20)      NOT NULL CONSTRAINT DF_Pedido_Estado DEFAULT (N'Pendiente'),
    MetodoPago       NVARCHAR(20)      NOT NULL,
    TipoEntrega      NVARCHAR(20)      NOT NULL,
    DireccionEntrega NVARCHAR(150)     NULL,
    Total            DECIMAL(10,2)     NOT NULL CONSTRAINT DF_Pedido_Total DEFAULT (0),
    CONSTRAINT PK_Pedido         PRIMARY KEY (IdPedido),
    CONSTRAINT FK_Pedido_Cliente FOREIGN KEY (IdCliente) REFERENCES dbo.Cliente (IdCliente),
    CONSTRAINT FK_Pedido_Usuario FOREIGN KEY (IdUsuario) REFERENCES dbo.UsuarioAdmin (IdUsuario),
    CONSTRAINT CK_Pedido_Estado  CHECK (Estado IN (N'Pendiente', N'Pagado', N'Enviado', N'Entregado', N'Cancelado')),
    CONSTRAINT CK_Pedido_Pago    CHECK (MetodoPago IN (N'Efectivo', N'Tarjeta', N'Yape', N'Plin', N'Transferencia')),
    CONSTRAINT CK_Pedido_Entrega CHECK (TipoEntrega IN (N'Recojo en tienda', N'Delivery')),
    CONSTRAINT CK_Pedido_Direccion CHECK (TipoEntrega <> N'Delivery' OR DireccionEntrega IS NOT NULL),
    CONSTRAINT CK_Pedido_Total   CHECK (Total >= 0)
);
GO

-- 2.7 Detalle de pedido (productos de cada pedido)
CREATE TABLE dbo.DetallePedido (
    IdDetalle      INT IDENTITY(1,1) NOT NULL,
    IdPedido       INT               NOT NULL,
    IdProducto     INT               NOT NULL,
    Cantidad       INT               NOT NULL,
    PrecioUnitario DECIMAL(10,2)     NOT NULL,
    Subtotal       AS (Cantidad * PrecioUnitario) PERSISTED,
    CONSTRAINT PK_DetallePedido          PRIMARY KEY (IdDetalle),
    CONSTRAINT FK_Detalle_Pedido         FOREIGN KEY (IdPedido)   REFERENCES dbo.Pedido (IdPedido) ON DELETE CASCADE,
    CONSTRAINT FK_Detalle_Producto       FOREIGN KEY (IdProducto) REFERENCES dbo.Producto (IdProducto),
    CONSTRAINT UQ_Detalle_Pedido_Producto UNIQUE (IdPedido, IdProducto),
    CONSTRAINT CK_Detalle_Cantidad       CHECK (Cantidad > 0),
    CONSTRAINT CK_Detalle_Precio         CHECK (PrecioUnitario >= 0)
);
GO

-- 2.8 Servicios que ofrece la tienda
CREATE TABLE dbo.Servicio (
    IdServicio        INT IDENTITY(1,1) NOT NULL,
    Nombre            NVARCHAR(80)      NOT NULL,
    Descripcion       NVARCHAR(300)     NULL,
    PrecioReferencial DECIMAL(10,2)     NULL,
    Activo            BIT               NOT NULL CONSTRAINT DF_Servicio_Activo DEFAULT (1),
    CONSTRAINT PK_Servicio        PRIMARY KEY (IdServicio),
    CONSTRAINT UQ_Servicio_Nombre UNIQUE (Nombre),
    CONSTRAINT CK_Servicio_Precio CHECK (PrecioReferencial IS NULL OR PrecioReferencial >= 0)
);
GO

-- 2.9 Solicitudes de servicio (asesoría, garantía, soporte, entrega)
CREATE TABLE dbo.SolicitudServicio (
    IdSolicitud    INT IDENTITY(1,1) NOT NULL,
    IdCliente      INT               NOT NULL,
    IdServicio     INT               NOT NULL,
    IdPedido       INT               NULL,      -- pedido relacionado (si aplica)
    FechaSolicitud DATETIME2(0)      NOT NULL CONSTRAINT DF_Solicitud_Fecha DEFAULT (SYSDATETIME()),
    Estado         NVARCHAR(20)      NOT NULL CONSTRAINT DF_Solicitud_Estado DEFAULT (N'Recibida'),
    Detalle        NVARCHAR(300)     NULL,
    CONSTRAINT PK_SolicitudServicio  PRIMARY KEY (IdSolicitud),
    CONSTRAINT FK_Solicitud_Cliente  FOREIGN KEY (IdCliente)  REFERENCES dbo.Cliente (IdCliente),
    CONSTRAINT FK_Solicitud_Servicio FOREIGN KEY (IdServicio) REFERENCES dbo.Servicio (IdServicio),
    CONSTRAINT FK_Solicitud_Pedido   FOREIGN KEY (IdPedido)   REFERENCES dbo.Pedido (IdPedido),
    CONSTRAINT CK_Solicitud_Estado   CHECK (Estado IN (N'Recibida', N'En proceso', N'Atendida', N'Cerrada'))
);
GO

-- 2.10 Consultas del formulario de contacto
CREATE TABLE dbo.ContactoConsulta (
    IdConsulta  INT IDENTITY(1,1) NOT NULL,
    IdCliente   INT               NULL,     
    Nombre      NVARCHAR(100)     NOT NULL,
    Correo      NVARCHAR(100)     NOT NULL,
    Telefono    CHAR(9)           NULL,
    Asunto      NVARCHAR(100)     NOT NULL,
    Mensaje     NVARCHAR(500)     NOT NULL,
    FechaEnvio  DATETIME2(0)      NOT NULL CONSTRAINT DF_Consulta_Fecha DEFAULT (SYSDATETIME()),
    Atendida    BIT               NOT NULL CONSTRAINT DF_Consulta_Atendida DEFAULT (0),
    CONSTRAINT PK_ContactoConsulta PRIMARY KEY (IdConsulta),
    CONSTRAINT FK_Consulta_Cliente FOREIGN KEY (IdCliente) REFERENCES dbo.Cliente (IdCliente),
    CONSTRAINT CK_Consulta_Correo  CHECK (Correo LIKE '%_@_%._%'),
    CONSTRAINT CK_Consulta_Tel     CHECK (Telefono IS NULL OR Telefono LIKE '9[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);
GO

/* ---------------------------------------------------------------------
   3. ÍNDICES (búsqueda, filtros y uniones frecuentes)
   --------------------------------------------------------------------- */
CREATE INDEX IX_Producto_IdCategoria  ON dbo.Producto (IdCategoria);
CREATE INDEX IX_Producto_IdPlataforma ON dbo.Producto (IdPlataforma);
CREATE INDEX IX_Producto_Nombre       ON dbo.Producto (Nombre);
CREATE INDEX IX_Producto_Destacados   ON dbo.Producto (Precio) INCLUDE (Nombre) WHERE Destacado = 1 AND Activo = 1;
CREATE INDEX IX_Pedido_IdCliente      ON dbo.Pedido (IdCliente);
CREATE INDEX IX_Pedido_FechaPedido    ON dbo.Pedido (FechaPedido);
CREATE INDEX IX_Detalle_IdProducto    ON dbo.DetallePedido (IdProducto);
CREATE INDEX IX_Solicitud_IdCliente   ON dbo.SolicitudServicio (IdCliente);
CREATE INDEX IX_Solicitud_Estado      ON dbo.SolicitudServicio (Estado);
GO

/* ---------------------------------------------------------------------
   4. DATOS DE PRUEBA
   --------------------------------------------------------------------- */

-- Categorías
INSERT INTO dbo.Categoria (Nombre, Descripcion) VALUES
(N'Acción y aventura', N'Juegos de acción, exploración y aventura'),
(N'Deportes',          N'Fútbol y otros deportes'),
(N'Carreras',          N'Juegos de conducción y velocidad'),
(N'Familiar',          N'Juegos para todas las edades'),
(N'Consolas',          N'Consolas de videojuegos'),
(N'Accesorios',        N'Controles y complementos');
GO

-- Plataformas
INSERT INTO dbo.Plataforma (Nombre, Fabricante) VALUES
(N'PlayStation 5',      N'Sony'),
(N'Xbox Series X|S',    N'Microsoft'),
(N'Nintendo Switch',    N'Nintendo');
GO

-- Productos
INSERT INTO dbo.Producto (IdCategoria, IdPlataforma, Nombre, Tipo, Descripcion, Precio, Stock, ImagenUrl, Destacado) VALUES
(5, 1, N'PlayStation 5 Slim Edición Disco 1TB', N'Consola',    N'Consola de nueva generación con lector de discos y SSD de 1TB.', 2399.00,  8, N'img/productos/ps5-slim.jpg',        1),
(5, 2, N'Xbox Series X 1TB',                    N'Consola',    N'Consola de Microsoft con juego en 4K y SSD de 1TB.',             2499.00,  5, N'img/productos/xbox-series-x.jpg',    1),
(5, 3, N'Nintendo Switch OLED 64GB',            N'Consola',    N'Consola híbrida con pantalla OLED de 7 pulgadas.',               1399.00, 12, N'img/productos/switch-oled.jpg',      1),
(5, 2, N'Xbox Series S 512GB',                  N'Consola',    N'Consola digital compacta, sin lector de discos.',                1199.00,  6, N'img/productos/xbox-series-s.jpg',    0),
(2, 1, N'EA Sports FC 26',                      N'Videojuego', N'Simulador de fútbol con ligas y clubes oficiales.',               249.00, 20, N'img/productos/fc26-ps5.jpg',          1),
(1, 1, N'God of War Ragnarök',                  N'Videojuego', N'Aventura de acción basada en la mitología nórdica.',              199.00, 15, N'img/productos/gow-ragnarok.jpg',      0),
(4, 3, N'Mario Kart 8 Deluxe',                  N'Videojuego', N'Carreras para toda la familia, hasta 4 jugadores.',               259.00, 14, N'img/productos/mario-kart-8.jpg',      1),
(1, 3, N'The Legend of Zelda: Tears of the Kingdom', N'Videojuego', N'Aventura de mundo abierto en Hyrule.',                       279.00, 10, N'img/productos/zelda-totk.jpg',        1),
(3, 2, N'Forza Horizon 5',                      N'Videojuego', N'Carreras de mundo abierto con autos de todo tipo.',               219.00,  9, N'img/productos/forza-horizon-5.jpg',   0),
(6, 1, N'Control inalámbrico DualSense',        N'Accesorio',  N'Control con respuesta háptica y gatillos adaptativos.',           299.00, 18, N'img/productos/dualsense.jpg',         0);
GO

-- Clientes
INSERT INTO dbo.Cliente (Dni, Nombres, Apellidos, Correo, Telefono, Direccion, Distrito, Departamento) VALUES
('45872316', N'Luis Alberto',     N'Quispe Mamani',    N'luis.quispe@gmail.com',     '987654321', N'Av. Petit Thouars 3540',  N'San Isidro',        N'Lima'),
('70234581', N'María Fernanda',   N'Torres Ríos',      N'mf.torres@outlook.com',     '986123457', N'Av. Larco 812',           N'Miraflores',        N'Lima'),
('41893267', N'Carlos Eduardo',   N'Huamán Flores',    N'carlos.huaman@gmail.com',   '945321876', N'Jr. de la Unión 455',     N'Cercado de Lima',   N'Lima'),
('72618945', N'Rosa Elena',       N'Vásquez Chávez',   N'rosa.vasquez@hotmail.com',  '912456789', N'Av. Universitaria 1840',  N'Los Olivos',        N'Lima'),
('46127389', N'Jorge Luis',       N'Mendoza Paredes',  N'jorge.mendoza@gmail.com',   '984765432', N'Av. El Sol 345',          N'Cusco',             N'Cusco'),
('43975218', N'Ana Lucía',        N'Cárdenas Rojas',   N'ana.cardenas@gmail.com',    '958234167', N'Calle Mercaderes 210',    N'Arequipa',          N'Arequipa'),
('71846392', N'Diego Alonso',     N'Ramírez Salazar',  N'diego.ramirez@gmail.com',   '973681524', N'Av. La Marina 2355',      N'San Miguel',        N'Lima'),
('40368125', N'Patricia Milagros',N'Gutiérrez León',   N'patricia.gutierrez@gmail.com','996125478', N'Av. Benavides 4120',    N'Santiago de Surco', N'Lima'),
('47291836', N'Miguel Ángel',     N'Rojas Campos',     N'miguel.rojas@outlook.com',  '947852136', N'Av. España 1450',         N'Trujillo',          N'La Libertad'),
('73518264', N'Sofía Valeria',    N'Delgado Ponce',    N'sofia.delgado@gmail.com',   '961357842', N'Av. Grau 540',            N'Piura',             N'Piura');
GO

-- Usuarios del panel de administración
-- Contraseñas de práctica: Admin2026!, Ventas2026!, Almacen2026! (se guardan solo como hash)
INSERT INTO dbo.UsuarioAdmin (Nombres, Correo, ClaveHash, Rol) VALUES
(N'Manuel Armando Caro Ulloa', N'admin@gamezone.pe',   HASHBYTES('SHA2_256', N'Admin2026!'),   N'Administrador'),
(N'Daniela Paredes Ruiz',      N'ventas@gamezone.pe',  HASHBYTES('SHA2_256', N'Ventas2026!'),  N'Vendedor'),
(N'Renzo Castillo Vargas',     N'almacen@gamezone.pe', HASHBYTES('SHA2_256', N'Almacen2026!'), N'Almacen');
GO

-- Pedidos
INSERT INTO dbo.Pedido (IdCliente, IdUsuario, FechaPedido, Estado, MetodoPago, TipoEntrega, DireccionEntrega) VALUES
(1, 2, '2026-10-03T11:20:00', N'Entregado', N'Yape',          N'Delivery',         N'Av. Petit Thouars 3540, San Isidro, Lima'),
(2, 2, '2026-10-07T16:45:00', N'Entregado', N'Tarjeta',       N'Recojo en tienda', NULL),
(3, 2, '2026-10-12T10:05:00', N'Entregado', N'Efectivo',      N'Recojo en tienda', NULL),
(5, 2, '2026-10-18T19:30:00', N'Enviado',   N'Transferencia', N'Delivery',         N'Av. El Sol 345, Cusco'),
(8, 2, '2026-10-24T13:15:00', N'Pagado',    N'Plin',          N'Delivery',         N'Av. Benavides 4120, Santiago de Surco, Lima'),
(6, 2, '2026-10-29T09:40:00', N'Pendiente', N'Yape',          N'Delivery',         N'Calle Mercaderes 210, Arequipa');
GO

-- Detalle de pedidos
INSERT INTO dbo.DetallePedido (IdPedido, IdProducto, Cantidad, PrecioUnitario) VALUES
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
GO

-- Cálculo del total de cada pedido a partir de su detalle
UPDATE p
SET    p.Total = d.TotalPedido
FROM   dbo.Pedido p
INNER JOIN (SELECT IdPedido, SUM(Subtotal) AS TotalPedido
            FROM dbo.DetallePedido
            GROUP BY IdPedido) d ON d.IdPedido = p.IdPedido;
GO

-- Servicios
INSERT INTO dbo.Servicio (Nombre, Descripcion, PrecioReferencial) VALUES
(N'Venta de consolas y videojuegos', N'Venta de productos nuevos con comprobante de pago.',            NULL),
(N'Asesoría personalizada',          N'Recomendación de consola o juegos según edad y presupuesto.',    0.00),
(N'Garantía de productos',           N'Garantía de 12 meses por defectos de fábrica en consolas.',      NULL),
(N'Soporte técnico',                 N'Diagnóstico y reparación básica de consolas y controles.',      80.00),
(N'Entrega a domicilio',             N'Delivery en Lima Metropolitana y envíos a provincias.',         15.00);
GO

-- Solicitudes de servicio 
INSERT INTO dbo.SolicitudServicio (IdCliente, IdServicio, IdPedido, FechaSolicitud, Estado, Detalle) VALUES
(1, 5, 1,    '2026-10-03T11:25:00', N'Atendida',   N'Entrega a domicilio en San Isidro.'),
(2, 2, NULL, '2026-10-06T15:10:00', N'Atendida',   N'Consulta sobre qué consola elegir para su hijo.'),
(3, 3, 3,    '2026-10-20T12:00:00', N'En proceso', N'Reclamo de garantía: el disco de God of War no es reconocido.'),
(5, 5, 4,    '2026-10-18T19:35:00', N'En proceso', N'Envío a Cusco mediante agencia de transporte.'),
(7, 4, NULL, '2026-10-25T17:20:00', N'Recibida',   N'La consola no enciende, solicita diagnóstico.'),
(8, 2, NULL, '2026-10-22T11:45:00', N'Cerrada',    N'Asesoría sobre juegos para Nintendo Switch.');
GO

-- Consultas de contacto (6)
INSERT INTO dbo.ContactoConsulta (IdCliente, Nombre, Correo, Telefono, Asunto, Mensaje, FechaEnvio, Atendida) VALUES
(NULL, N'Jimena Alva Soto',   N'jimena.alva@hotmail.com',  '955123478', N'Consulta de stock',   N'¿Tienen disponible el PlayStation 5 y hacen envíos a Chiclayo?',          '2026-10-02T09:12:00', 1),
(4,    N'Rosa Vásquez Chávez',N'rosa.vasquez@hotmail.com', '912456789', N'Garantía',            N'Quisiera saber cuánto dura la garantía de las consolas.',                  '2026-10-09T18:30:00', 1),
(NULL, N'Pedro Salinas Cruz', N'pedro.salinas@gmail.com',  NULL,        N'Horario de atención', N'¿Atienden los domingos? Quiero recoger un pedido.',                        '2026-10-15T20:05:00', 1),
(NULL, N'Lucero Benites Díaz',N'lucero.benites@gmail.com', '964782135', N'Juegos para niños',   N'Busco un juego para mi hijo de 8 años, ¿qué me recomiendan?',              '2026-10-21T14:40:00', 0),
(9,    N'Miguel Rojas Campos',N'miguel.rojas@outlook.com', '947852136', N'Envío a Trujillo',    N'¿Cuánto demora el envío a Trujillo y cuál es el costo?',                   '2026-10-27T10:55:00', 0),
(NULL, N'Andrea Núñez Bravo', N'andrea.nunez@gmail.com',   '938456721', N'Precio al por mayor', N'Necesito cotizar 5 controles DualSense para un torneo de mi universidad.', '2026-10-30T16:20:00', 0);
GO

/* ---------------------------------------------------------------------
   5. VISTA
   --------------------------------------------------------------------- */
CREATE VIEW dbo.vw_ResumenPedidos
AS
SELECT  p.IdPedido,
        p.FechaPedido,
        c.Nombres + N' ' + c.Apellidos AS Cliente,
        p.Estado,
        p.MetodoPago,
        p.TipoEntrega,
        p.Total,
        u.Nombres AS Vendedor
FROM    dbo.Pedido p
INNER JOIN dbo.Cliente c      ON c.IdCliente = p.IdCliente
LEFT  JOIN dbo.UsuarioAdmin u ON u.IdUsuario = p.IdUsuario;
GO

/* ---------------------------------------------------------------------
   6. PROCEDIMIENTOS ALMACENADOS
   --------------------------------------------------------------------- */

-- 6.1 Registra la cabecera de un pedido nuevo (estado Pendiente)
CREATE PROCEDURE dbo.sp_RegistrarPedido
    @IdCliente        INT,
    @IdUsuario        INT = NULL,
    @MetodoPago       NVARCHAR(20),
    @TipoEntrega      NVARCHAR(20),
    @DireccionEntrega NVARCHAR(150) = NULL,
    @IdPedido         INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Cliente WHERE IdCliente = @IdCliente AND Activo = 1)
        THROW 50001, N'El cliente no existe o está inactivo.', 1;

    INSERT INTO dbo.Pedido (IdCliente, IdUsuario, MetodoPago, TipoEntrega, DireccionEntrega)
    VALUES (@IdCliente, @IdUsuario, @MetodoPago, @TipoEntrega, @DireccionEntrega);

    SET @IdPedido = SCOPE_IDENTITY();
END
GO

-- 6.2 Agrega un producto a un pedido pendiente: valida stock, descuenta stock y recalcula el total
CREATE PROCEDURE dbo.sp_AgregarDetallePedido
    @IdPedido   INT,
    @IdProducto INT,
    @Cantidad   INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Estado NVARCHAR(20), @Precio DECIMAL(10,2), @Stock INT;

        SELECT @Estado = Estado FROM dbo.Pedido WITH (UPDLOCK) WHERE IdPedido = @IdPedido;
        IF @Estado IS NULL
            THROW 50010, N'El pedido no existe.', 1;
        IF @Estado <> N'Pendiente'
            THROW 50011, N'Solo se pueden agregar productos a pedidos pendientes.', 1;
        IF @Cantidad IS NULL OR @Cantidad <= 0
            THROW 50012, N'La cantidad debe ser mayor que cero.', 1;

        SELECT @Precio = Precio, @Stock = Stock
        FROM dbo.Producto WITH (UPDLOCK)
        WHERE IdProducto = @IdProducto AND Activo = 1;
        IF @Precio IS NULL
            THROW 50013, N'El producto no existe o está inactivo.', 1;
        IF @Stock < @Cantidad
            THROW 50014, N'Stock insuficiente para el producto solicitado.', 1;
        IF EXISTS (SELECT 1 FROM dbo.DetallePedido WHERE IdPedido = @IdPedido AND IdProducto = @IdProducto)
            THROW 50015, N'El producto ya fue agregado a este pedido.', 1;

        INSERT INTO dbo.DetallePedido (IdPedido, IdProducto, Cantidad, PrecioUnitario)
        VALUES (@IdPedido, @IdProducto, @Cantidad, @Precio);

        UPDATE dbo.Producto SET Stock = Stock - @Cantidad WHERE IdProducto = @IdProducto;

        UPDATE dbo.Pedido
        SET    Total = (SELECT SUM(Subtotal) FROM dbo.DetallePedido WHERE IdPedido = @IdPedido)
        WHERE  IdPedido = @IdPedido;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 6.3 Cambia el estado de un pedido; si se cancela, devuelve el stock
CREATE PROCEDURE dbo.sp_CambiarEstadoPedido
    @IdPedido    INT,
    @NuevoEstado NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @EstadoActual NVARCHAR(20);

        SELECT @EstadoActual = Estado FROM dbo.Pedido WITH (UPDLOCK) WHERE IdPedido = @IdPedido;
        IF @EstadoActual IS NULL
            THROW 50020, N'El pedido no existe.', 1;
        IF @EstadoActual IN (N'Entregado', N'Cancelado')
            THROW 50021, N'Un pedido entregado o cancelado ya no puede cambiar de estado.', 1;

        IF @NuevoEstado = N'Cancelado'
        BEGIN
            UPDATE pr
            SET    pr.Stock = pr.Stock + d.Cantidad
            FROM   dbo.Producto pr
            INNER JOIN dbo.DetallePedido d ON d.IdProducto = pr.IdProducto
            WHERE  d.IdPedido = @IdPedido;
        END

        UPDATE dbo.Pedido SET Estado = @NuevoEstado WHERE IdPedido = @IdPedido;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

/* ---------------------------------------------------------------------
   7. VERIFICACIÓN: 
   --------------------------------------------------------------------- */
SELECT N'Categoria' AS Tabla, COUNT(*) AS Registros FROM dbo.Categoria
UNION ALL SELECT N'Plataforma',        COUNT(*) FROM dbo.Plataforma
UNION ALL SELECT N'Producto',          COUNT(*) FROM dbo.Producto
UNION ALL SELECT N'Cliente',           COUNT(*) FROM dbo.Cliente
UNION ALL SELECT N'UsuarioAdmin',      COUNT(*) FROM dbo.UsuarioAdmin
UNION ALL SELECT N'Pedido',            COUNT(*) FROM dbo.Pedido
UNION ALL SELECT N'DetallePedido',     COUNT(*) FROM dbo.DetallePedido
UNION ALL SELECT N'Servicio',          COUNT(*) FROM dbo.Servicio
UNION ALL SELECT N'SolicitudServicio', COUNT(*) FROM dbo.SolicitudServicio
UNION ALL SELECT N'ContactoConsulta',  COUNT(*) FROM dbo.ContactoConsulta;
GO

SELECT * FROM dbo.vw_ResumenPedidos ORDER BY IdPedido;
GO

SELECT * FROM dbo.DetallePedido
GO
SELECT * FROM dbo.Producto
GO
