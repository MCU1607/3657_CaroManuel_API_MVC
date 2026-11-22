<?php

namespace App\Models;

use PDO;

class UsuarioAdmin
{
    private PDO $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    // Nunca se devuelve ClaveHash
    public function obtenerTodos(): array
    {
        $sql = "
            SELECT IdUsuario, Nombres, Correo, Rol, Activo, FechaCreacion
            FROM UsuarioAdmin
            WHERE Activo = 1
            ORDER BY Nombres
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    public function obtenerPorId(int $id): array|false
    {
        $sql = "
            SELECT IdUsuario, Nombres, Correo, Rol, Activo, FechaCreacion
            FROM UsuarioAdmin
            WHERE IdUsuario = :id
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute([':id' => $id]);

        return $stmt->fetch();
    }

    // ClaveHash es BINARY(32): SHA-256 guardado igual que UNHEX(SHA2(clave, 256))
    public function crear(array $data): bool
    {
        $sql = "
            INSERT INTO UsuarioAdmin (Nombres, Correo, ClaveHash, Rol, Activo)
            VALUES (:nombres, :correo, UNHEX(:clave), :rol, 1)
        ";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([
            ':nombres' => $data['Nombres'],
            ':correo' => $data['Correo'],
            ':clave' => hash('sha256', $data['Clave']),
            ':rol' => $data['Rol']
        ]);
    }

    public function actualizar(int $id, array $data): bool
    {
        $params = [
            ':nombres' => $data['Nombres'],
            ':correo' => $data['Correo'],
            ':rol' => $data['Rol'],
            ':id' => $id
        ];

        $claveSql = '';

        // La clave solo se cambia si se envía
        if (!empty($data['Clave'])) {
            $claveSql = ', ClaveHash = UNHEX(:clave)';
            $params[':clave'] = hash('sha256', $data['Clave']);
        }

        $sql = "
            UPDATE UsuarioAdmin
            SET Nombres = :nombres,
                Correo = :correo,
                Rol = :rol
                $claveSql
            WHERE IdUsuario = :id
        ";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute($params);
    }

    public function eliminar(int $id): bool
    {
        $sql = "UPDATE UsuarioAdmin SET Activo = 0 WHERE IdUsuario = :id";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([':id' => $id]);
    }
}