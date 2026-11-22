<?php

namespace App\Models;

use PDO;

class SolicitudServicio
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
                s.IdSolicitud,
                s.IdCliente,
                CONCAT(c.Nombres, ' ', c.Apellidos) AS Cliente,
                s.IdServicio,
                sv.Nombre AS Servicio,
                s.IdPedido,
                s.FechaSolicitud,
                s.Estado,
                s.Detalle
            FROM SolicitudServicio s
            INNER JOIN Cliente c   ON c.IdCliente = s.IdCliente
            INNER JOIN Servicio sv ON sv.IdServicio = s.IdServicio
            ORDER BY s.FechaSolicitud DESC
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    public function obtenerPorId(int $id): array|false
    {
        $sql = "
            SELECT
                s.IdSolicitud,
                s.IdCliente,
                CONCAT(c.Nombres, ' ', c.Apellidos) AS Cliente,
                s.IdServicio,
                sv.Nombre AS Servicio,
                s.IdPedido,
                s.FechaSolicitud,
                s.Estado,
                s.Detalle
            FROM SolicitudServicio s
            INNER JOIN Cliente c   ON c.IdCliente = s.IdCliente
            INNER JOIN Servicio sv ON sv.IdServicio = s.IdServicio
            WHERE s.IdSolicitud = :id
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute([':id' => $id]);

        return $stmt->fetch();
    }

    public function crear(array $data): bool
    {
        $sql = "
            INSERT INTO SolicitudServicio
                (IdCliente, IdServicio, IdPedido, Estado, Detalle)
            VALUES
                (:cliente, :servicio, :pedido, 'Recibida', :detalle)
        ";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([
            ':cliente' => $data['IdCliente'],
            ':servicio' => $data['IdServicio'],
            ':pedido' => $data['IdPedido'] ?? null,
            ':detalle' => $data['Detalle'] ?? null
        ]);
    }

    public function actualizar(int $id, array $data): bool
    {
        $sql = "
            UPDATE SolicitudServicio
            SET IdCliente = :cliente,
                IdServicio = :servicio,
                IdPedido = :pedido,
                Detalle = :detalle
            WHERE IdSolicitud = :id
        ";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([
            ':cliente' => $data['IdCliente'],
            ':servicio' => $data['IdServicio'],
            ':pedido' => $data['IdPedido'] ?? null,
            ':detalle' => $data['Detalle'] ?? null,
            ':id' => $id
        ]);
    }

    public function cambiarEstado(int $id, string $estado): bool
    {
        $sql = "
            UPDATE SolicitudServicio
            SET Estado = :estado
            WHERE IdSolicitud = :id
        ";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([
            ':estado' => $estado,
            ':id' => $id
        ]);
    }

    public function eliminar(int $id): bool
    {
        $sql = "DELETE FROM SolicitudServicio WHERE IdSolicitud = :id";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([':id' => $id]);
    }
}