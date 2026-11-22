<?php

/** @var \PDO $db */
/** @var \Core\Router $router */

use App\Controllers\CategoriaController;
use App\Controllers\PlataformaController;
use App\Controllers\ProductoController;
use App\Controllers\ClienteController;
use App\Controllers\UsuarioAdminController;
use App\Controllers\PedidoController;
use App\Controllers\DetallePedidoController;
use App\Controllers\ServicioController;
use App\Controllers\SolicitudServicioController;
use App\Controllers\ContactoConsultaController;


// ==========================================================
// INSTANCIAR CONTROLLERS
// ==========================================================

$categoriaController = new CategoriaController($db);

$plataformaController = new PlataformaController($db);

$productoController = new ProductoController($db);

$clienteController = new ClienteController($db);

$usuarioAdminController = new UsuarioAdminController($db);

$pedidoController = new PedidoController($db);

$detallePedidoController = new DetallePedidoController($db);

$servicioController = new ServicioController($db);

$solicitudController = new SolicitudServicioController($db);

$contactoController = new ContactoConsultaController($db);


// ==========================================================
// CATEGORÍAS
// ==========================================================

$router->get('/api/categorias', [$categoriaController, 'index']);

$router->get('/api/categorias/{id}', [$categoriaController, 'show']);

$router->post('/api/categorias', [$categoriaController, 'store']);

$router->put('/api/categorias/{id}', [$categoriaController, 'update']);

$router->delete('/api/categorias/{id}', [$categoriaController, 'destroy']);


// ==========================================================
// PLATAFORMAS
// ==========================================================

$router->get('/api/plataformas', [$plataformaController, 'index']);

$router->get('/api/plataformas/{id}', [$plataformaController, 'show']);

$router->post('/api/plataformas', [$plataformaController, 'store']);

$router->put('/api/plataformas/{id}', [$plataformaController, 'update']);

$router->delete('/api/plataformas/{id}', [$plataformaController, 'destroy']);


// ==========================================================
// PRODUCTOS
// ==========================================================

$router->get('/api/productos', [$productoController, 'index']);

$router->get('/api/productos/{id}', [$productoController, 'show']);

$router->post('/api/productos', [$productoController, 'store']);

$router->put('/api/productos/{id}', [$productoController, 'update']);

$router->delete('/api/productos/{id}', [$productoController, 'destroy']);


// ==========================================================
// CLIENTES
// ==========================================================

$router->get('/api/clientes', [$clienteController, 'index']);

$router->get('/api/clientes/{id}', [$clienteController, 'show']);

$router->post('/api/clientes', [$clienteController, 'store']);

$router->put('/api/clientes/{id}', [$clienteController, 'update']);

$router->delete('/api/clientes/{id}', [$clienteController, 'destroy']);


// ==========================================================
// USUARIOS ADMIN
// ==========================================================

$router->get('/api/usuarios', [$usuarioAdminController, 'index']);

$router->get('/api/usuarios/{id}', [$usuarioAdminController, 'show']);

$router->post('/api/usuarios', [$usuarioAdminController, 'store']);

$router->put('/api/usuarios/{id}', [$usuarioAdminController, 'update']);

$router->delete('/api/usuarios/{id}', [$usuarioAdminController, 'destroy']);


// ==========================================================
// PEDIDOS (cabecera + detalle)
// ==========================================================

// Listar pedidos
$router->get('/api/pedidos', [$pedidoController, 'index']);

// Obtener pedido + detalles
$router->get('/api/pedidos/{id}', [$pedidoController, 'show']);

// Crear pedido con sus detalles
$router->post('/api/pedidos', [$pedidoController, 'store']);

// Cambiar estado del pedido (Cancelado devuelve el stock)
$router->put('/api/pedidos/{id}/estado', [$pedidoController, 'cambiarEstado']);

// ==========================================================
// DETALLE DE PEDIDO
// ==========================================================

// Listar productos de un pedido
$router->get(
    '/api/pedidos/{id}/detalles',
    [$detallePedidoController, 'index']
);

// Agregar producto a un pedido pendiente
$router->post(
    '/api/pedidos/{id}/detalles',
    [$detallePedidoController, 'store']
);

// Obtener un detalle
$router->get(
    '/api/detalles/{id}',
    [$detallePedidoController, 'show']
);

// Quitar producto de un pedido pendiente (devuelve stock)
$router->delete(
    '/api/detalles/{id}',
    [$detallePedidoController, 'destroy']
);


// ==========================================================
// SERVICIOS
// ==========================================================

$router->get('/api/servicios', [$servicioController, 'index']);

$router->get('/api/servicios/{id}', [$servicioController, 'show']);

$router->post('/api/servicios', [$servicioController, 'store']);

$router->put('/api/servicios/{id}', [$servicioController, 'update']);

$router->delete('/api/servicios/{id}', [$servicioController, 'destroy']);


// ==========================================================
// SOLICITUDES DE SERVICIO
// ==========================================================

$router->get('/api/solicitudes', [$solicitudController, 'index']);

$router->get('/api/solicitudes/{id}', [$solicitudController, 'show']);

$router->post('/api/solicitudes', [$solicitudController, 'store']);

$router->put('/api/solicitudes/{id}', [$solicitudController, 'update']);

// Cambiar estado de la solicitud
$router->put('/api/solicitudes/{id}/estado', [$solicitudController, 'cambiarEstado']);

$router->delete('/api/solicitudes/{id}', [$solicitudController, 'destroy']);


// ==========================================================
// CONTACTO (consultas del formulario)
// ==========================================================

$router->get('/api/contactos', [$contactoController, 'index']);

$router->get('/api/contactos/{id}', [$contactoController, 'show']);

$router->post('/api/contactos', [$contactoController, 'store']);

$router->put('/api/contactos/{id}', [$contactoController, 'update']);

// Marcar consulta como atendida
$router->put('/api/contactos/{id}/atendida', [$contactoController, 'marcarAtendida']);

$router->delete('/api/contactos/{id}', [$contactoController, 'destroy']);