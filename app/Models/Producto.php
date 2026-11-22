<?php

namespace App\Models;

use PDO;

class Producto
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
                p.IdProducto,
                p.IdCategoria,
                c.Nombre AS Categoria,
                p.IdPlataforma,
                pl.Nombre AS Plataforma,
                p.Nombre,
                p.Tipo,
                p.Descripcion,
                p.Precio,
                p.Stock,
                p.ImagenUrl,
                p.Destacado,
                p.Activo,
                p.FechaRegistro
            FROM Producto p
            INNER JOIN Categoria c   ON c.IdCategoria = p.IdCategoria
            INNER JOIN Plataforma pl ON pl.IdPlataforma = p.IdPlataforma
            WHERE p.Activo = 1
            ORDER BY p.Nombre
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    public function obtenerPorId(int $id): array|false
    {
        $sql = "
            SELECT
                p.IdProducto,
                p.IdCategoria,
                c.Nombre AS Categoria,
                p.IdPlataforma,
                pl.Nombre AS Plataforma,
                p.Nombre,
                p.Tipo,
                p.Descripcion,
                p.Precio,
                p.Stock,
                p.ImagenUrl,
                p.Destacado,
                p.Activo,
                p.FechaRegistro
            FROM Producto p
            INNER JOIN Categoria c   ON c.IdCategoria = p.IdCategoria
            INNER JOIN Plataforma pl ON pl.IdPlataforma = p.IdPlataforma
            WHERE p.IdProducto = :id
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute([':id' => $id]);

        return $stmt->fetch();
    }

    public function crear(array $data): bool
    {
        $sql = "
            INSERT INTO Producto
            (
                IdCategoria, IdPlataforma, Nombre, Tipo,
                Descripcion, Precio, Stock, ImagenUrl, Destacado, Activo
            )
            VALUES
            (
                :categoria, :plataforma, :nombre, :tipo,
                :descripcion, :precio, :stock, :imagen, :destacado, 1
            )
        ";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([
            ':categoria' => $data['IdCategoria'],
            ':plataforma' => $data['IdPlataforma'],
            ':nombre' => $data['Nombre'],
            ':tipo' => $data['Tipo'],
            ':descripcion' => $data['Descripcion'] ?? null,
            ':precio' => $data['Precio'],
            ':stock' => $data['Stock'] ?? 0,
            ':imagen' => $data['ImagenUrl'] ?? null,
            ':destacado' => !empty($data['Destacado']) ? 1 : 0
        ]);
    }

    public function actualizar(int $id, array $data): bool
    {
        $sql = "
            UPDATE Producto
            SET IdCategoria = :categoria,
                IdPlataforma = :plataforma,
                Nombre = :nombre,
                Tipo = :tipo,
                Descripcion = :descripcion,
                Precio = :precio,
                Stock = :stock,
                ImagenUrl = :imagen,
                Destacado = :destacado
            WHERE IdProducto = :id
        ";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([
            ':categoria' => $data['IdCategoria'],
            ':plataforma' => $data['IdPlataforma'],
            ':nombre' => $data['Nombre'],
            ':tipo' => $data['Tipo'],
            ':descripcion' => $data['Descripcion'] ?? null,
            ':precio' => $data['Precio'],
            ':stock' => $data['Stock'] ?? 0,
            ':imagen' => $data['ImagenUrl'] ?? null,
            ':destacado' => !empty($data['Destacado']) ? 1 : 0,
            ':id' => $id
        ]);
    }

    public function eliminar(int $id): bool
    {
        $sql = "UPDATE Producto SET Activo = 0 WHERE IdProducto = :id";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([':id' => $id]);
    }
}