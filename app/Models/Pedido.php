<?php

namespace App\Models;

use PDO;
use PDOException;

class Pedido
{
    private PDO $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    public function obtenerTodos(): array
    {
        $sql = "
            SELECT
                IdPedido, FechaPedido, Cliente, Estado,
                MetodoPago, TipoEntrega, Total, Vendedor
            FROM vw_ResumenPedidos
            ORDER BY IdPedido DESC
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    public function obtenerPorId(int $id): array|false
    {
        $sql = "
            SELECT
                p.IdPedido,
                p.IdCliente,
                CONCAT(c.Nombres, ' ', c.Apellidos) AS Cliente,
                p.IdUsuario,
                p.FechaPedido,
                p.Estado,
                p.MetodoPago,
                p.TipoEntrega,
                p.DireccionEntrega,
                p.Total
            FROM Pedido p
            INNER JOIN Cliente c ON c.IdCliente = p.IdCliente
            WHERE p.IdPedido = :id
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute([':id' => $id]);

        return $stmt->fetch();
    }

    public function obtenerDetalles(int $idPedido): array
    {
        $sql = "
            SELECT
                d.IdDetalle,
                d.IdProducto,
                pr.Nombre AS Producto,
                d.Cantidad,
                d.PrecioUnitario,
                d.Subtotal
            FROM DetallePedido d
            INNER JOIN Producto pr ON pr.IdProducto = d.IdProducto
            WHERE d.IdPedido = :id
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute([':id' => $idPedido]);

        return $stmt->fetchAll();
    }

    /**
     * Registra la cabecera y sus detalles usando los procedimientos almacenados.
     * Si falla un detalle (stock insuficiente, producto inactivo, etc.),
     * se devuelve el stock y se elimina el pedido incompleto.
     */
    public function crear(array $data): int
    {
        $stmt = $this->db->prepare(
            "CALL sp_RegistrarPedido(:cliente, :usuario, :pago, :entrega, :direccion, @p_id)"
        );

        $stmt->execute([
            ':cliente' => $data['IdCliente'],
            ':usuario' => $data['IdUsuario'] ?? null,
            ':pago' => $data['MetodoPago'],
            ':entrega' => $data['TipoEntrega'],
            ':direccion' => $data['DireccionEntrega'] ?? null
        ]);
        $stmt->closeCursor();

        $idPedido = (int) $this->db->query("SELECT @p_id")->fetchColumn();

        try {
            foreach ($data['detalles'] as $detalle) {
                $sp = $this->db->prepare(
                    "CALL sp_AgregarDetallePedido(:pedido, :producto, :cantidad)"
                );

                $sp->execute([
                    ':pedido' => $idPedido,
                    ':producto' => $detalle['IdProducto'],
                    ':cantidad' => $detalle['Cantidad']
                ]);
                $sp->closeCursor();
            }
        } catch (PDOException $e) {
            $this->cambiarEstado($idPedido, 'Cancelado');

            $del = $this->db->prepare("DELETE FROM Pedido WHERE IdPedido = :id");
            $del->execute([':id' => $idPedido]);

            throw $e;
        }

        return $idPedido;
    }

    // Si el nuevo estado es Cancelado, el procedimiento devuelve el stock
    public function cambiarEstado(int $id, string $estado): bool
    {
        $stmt = $this->db->prepare("CALL sp_CambiarEstadoPedido(:id, :estado)");

        $ok = $stmt->execute([
            ':id' => $id,
            ':estado' => $estado
        ]);
        $stmt->closeCursor();

        return $ok;
    }
}