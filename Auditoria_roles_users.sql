-- =============================================
-- PLAN DE AUDITORÍA Y SEGURIDAD – HUELLASVERDES
-- ADAPTADO PARA POSTGRESQL + PGADMIN
-- =============================================

-- =============================
-- 1. CREACIÓN DE ROLES
-- =============================

-- Rol solo lectura
CREATE ROLE rol_lectura NOINHERIT;
GRANT CONNECT ON DATABASE "HuellasVerdes" TO rol_lectura;
GRANT USAGE ON SCHEMA compradores, transacciones, articulos TO rol_lectura;
GRANT SELECT ON ALL TABLES IN SCHEMA compradores, transacciones, articulos TO rol_lectura;

-- Rol de edición
CREATE ROLE rol_editor NOINHERIT;
GRANT CONNECT ON DATABASE "HuellasVerdes" TO rol_editor;
GRANT USAGE ON SCHEMA compradores, transacciones, articulos TO rol_editor;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA compradores, transacciones, articulos TO rol_editor;

-- Rol administrador
CREATE ROLE rol_admin NOINHERIT;
GRANT ALL PRIVILEGES ON DATABASE "HuellasVerdes" TO rol_admin;
GRANT ALL PRIVILEGES ON SCHEMA compradores, transacciones, articulos, administrador TO rol_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA compradores, transacciones, articulos, administrador TO rol_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA compradores, transacciones, articulos, administrador TO rol_admin;

-- =============================
-- 2. CREACIÓN DE USUARIOS
-- =============================

-- Usuario lector
CREATE USER user_lector WITH ENCRYPTED PASSWORD 'lector123';
GRANT rol_lectura TO user_lector;

-- Usuario editor
CREATE USER user_editor WITH ENCRYPTED PASSWORD 'editor123';
GRANT rol_editor TO user_editor;

-- Usuario administrador
CREATE USER user_admin WITH ENCRYPTED PASSWORD 'admin123';
GRANT rol_admin TO user_admin;

-- =============================
-- 3. AUDITORÍA MANUAL A NIVEL BD
-- =============================

-- Crear esquema para administración y logs
CREATE SCHEMA IF NOT EXISTS administrador;

-- Tabla de auditoría manual
CREATE TABLE IF NOT EXISTS administrador.AuditLog (
    id SERIAL PRIMARY KEY,
    usuario VARCHAR(100),
    accion TEXT,
    tabla_afectada TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT
);

-- Función de auditoría para tabla Transaccion
CREATE OR REPLACE FUNCTION administrador.log_transaccion()
RETURNS trigger AS $$
BEGIN
  INSERT INTO administrador.AuditLog (usuario, accion, tabla_afectada, descripcion)
  VALUES (current_user, TG_OP, 'transacciones.Transaccion',
          'ID: ' || COALESCE(NEW.idTransaccion::TEXT, OLD.idTransaccion::TEXT));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para auditoría
DROP TRIGGER IF EXISTS trg_log_transaccion ON transacciones.Transaccion;

CREATE TRIGGER trg_log_transaccion
AFTER INSERT OR UPDATE OR DELETE ON transacciones.Transaccion
FOR EACH ROW EXECUTE FUNCTION administrador.log_transaccion();

