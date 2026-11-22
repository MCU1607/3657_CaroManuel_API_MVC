<?php

namespace App\Models;

use PDO;
use RuntimeException;
use Throwable;

class DetallePedido
{
    private PDO $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    public function obtenerPorPedido(int $idPedido): array
    {
        $sql = "
            SELECT
                d.IdDetalle,
                d.IdPedido,
                d.IdProducto,
                pr.Nombre AS Producto,
                d.Cantidad,
                d.PrecioUnitario,
                d.Subtotal
            FROM DetallePedido d
            INNER JOIN Producto pr ON pr.IdProducto = d.IdProducto
            WHERE d.IdPedido = :id
            ORDER BY d.IdDetalle
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute([':id' => $idPedido]);

        return $stmt->fetchAll();
    }

    public function obtenerPorId(int $id): array|false
    {
        $sql = "
            SELECT
                d.IdDetalle,
                d.IdPedido,
                d.IdProducto,
                pr.Nombre AS Producto,
                d.Cantidad,
                d.PrecioUnitario,
                d.Subtotal
            FROM DetallePedido d
            INNER JOIN Producto pr ON pr.IdProducto = d.IdProducto
            WHERE d.IdDetalle = :id
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute([':id' => $id]);

        return $stmt->fetch();
    }

    // Valida pedido pendiente, stock y duplicados; descuenta stock y recalcula total
    public function agregar(int $idPedido, array $data): bool
    {
        $stmt = $this->db->prepare(
            "CALL sp_AgregarDetallePedido(:pedido, :producto, :cantidad)"
        );

        $ok = $stmt->execute([
            ':pedido' => $idPedido,
            ':producto' => $data['IdProducto'],
            ':cantidad' => $data['Cantidad']
        ]);
        $stmt->closeCursor();

        return $ok;
    }

    // Solo en pedidos Pendiente: devuelve el stock, borra el detalle y recalcula el total
    public function eliminar(int $id): bool
    {
        $this->db->beginTransaction();

        try {
            $stmt = $this->db->prepare("
                SELECT d.IdPedido, d.IdProducto, d.Cantidad, p.Estado
                FROM DetallePedido d
                INNER JOIN Pedido p ON p.IdPedido = d.IdPedido
                WHERE d.IdDetalle = :id
                FOR UPDATE
            ");
            $stmt->execute([':id' => $id]);
            $detalle = $stmt->fetch();

            if (!$detalle) {
                throw new RuntimeException('Detalle no encontrado');
            }

            if ($detalle['Estado'] !== 'Pendiente') {
                throw new RuntimeException(
                    'Solo se pueden quitar productos de pedidos pendientes'
                );
            }

            $stmt = $this->db->prepare("
                UPDATE Producto
                SET Stock = Stock + :cantidad
                WHERE IdProducto = :producto
            ");
            $stmt->execute([
                ':cantidad' => $detalle['Cantidad'],
                ':producto' => $detalle['IdProducto']
            ]);

            $stmt = $this->db->prepare("DELETE FROM DetallePedido WHERE IdDetalle = :id");
            $stmt->execute([':id' => $id]);

            $stmt = $this->db->prepare("
                UPDATE Pedido
                SET Total = (
                    SELECT COALESCE(SUM(Subtotal), 0)
                    FROM DetallePedido
                    WHERE IdPedido = :pedido
                )
                WHERE IdPedido = :pedido2
            ");
            $stmt->execute([
                ':pedido' => $detalle['IdPedido'],
                ':pedido2' => $detalle['IdPedido']
            ]);

            $this->db->commit();

            return true;
        } catch (Throwable $e) {
            $this->db->rollBack();
            throw $e;
        }
    }
}