-- Contador de búsquedas por cuenta.
-- Opción B: pegar esto en el SQL Editor de Neon si preferís no usar
-- `prisma migrate dev` / `prisma db push`. Es lo mismo que genera Prisma.

-- 1. Columna con el total ya calculado (contador "cacheado").
ALTER TABLE "Usuario" ADD COLUMN "busquedasTotal" INTEGER NOT NULL DEFAULT 0;

-- 2. Historial: una fila por búsqueda.
CREATE TABLE "Busqueda" (
    "id" SERIAL NOT NULL,
    "idUsuario" INTEGER NOT NULL,
    "destino" TEXT NOT NULL,
    "huespedes" INTEGER NOT NULL,
    "fecha" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Busqueda_pkey" PRIMARY KEY ("id")
);

-- 3. Índice: hace instantáneo contar/listar las búsquedas de UN usuario.
CREATE INDEX "Busqueda_idUsuario_fecha_idx" ON "Busqueda"("idUsuario", "fecha" DESC);

-- 4. Relación con Usuario. ON DELETE CASCADE: si se borra la cuenta,
--    se borra su historial automáticamente.
ALTER TABLE "Busqueda" ADD CONSTRAINT "Busqueda_idUsuario_fkey"
  FOREIGN KEY ("idUsuario") REFERENCES "Usuario"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;

-- ---------------------------------------------------------------------------
-- Consultas útiles (no hace falta ejecutarlas ahora)
-- ---------------------------------------------------------------------------

-- Total de un usuario, contando el historial (usa el índice de arriba):
-- SELECT COUNT(*) AS total FROM "Busqueda" WHERE "idUsuario" = $1;

-- Ranking de usuarios y sus búsquedas en UNA sola consulta (sin N+1):
-- SELECT u.id, u.gmail, COUNT(b.id) AS busquedas
--   FROM "Usuario" u
--   LEFT JOIN "Busqueda" b ON b."idUsuario" = u.id
--  GROUP BY u.id, u.gmail
--  ORDER BY busquedas DESC;

-- Reparar todos los contadores desde el historial (subconsulta):
-- UPDATE "Usuario" u
--    SET "busquedasTotal" = (SELECT COUNT(*) FROM "Busqueda" b WHERE b."idUsuario" = u.id);
