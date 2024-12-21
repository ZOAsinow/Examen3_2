create DataBASE Examen3_2;

use Examen3_2;

CREATE TABLE Departamentos (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(100) UNIQUE NOT NULL,
    Descripcion NVARCHAR(255),
    CONSTRAINT chk_nombre_departamento CHECK (LEN(Nombre) > 2)
);

-- Creación de la tabla Empleados
CREATE TABLE Empleados (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    NumeroCarnet NVARCHAR(20) UNIQUE NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Categoria NVARCHAR(20) CHECK (Categoria IN ('Administrador', 'Operario', 'Peón')) NOT NULL,
    Salario DECIMAL(10,2) NOT NULL CONSTRAINT chk_salario CHECK (Salario BETWEEN 250000 AND 500000),
    Direccion NVARCHAR(255) DEFAULT 'San José',
    Telefono NVARCHAR(15),
    Correo NVARCHAR(100) UNIQUE NOT NULL,
    DepartamentoId INT NULL,
    CONSTRAINT fk_departamento FOREIGN KEY (DepartamentoId) REFERENCES Departamentos(Id) ON DELETE SET NULL,
    CONSTRAINT chk_mayor_edad CHECK (DATEDIFF(YEAR, FechaNacimiento, GETDATE()) >= 18)
);

-- Creación de la tabla Proyectos
CREATE TABLE Proyectos (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Codigo NVARCHAR(20) UNIQUE NOT NULL,
    Nombre NVARCHAR(100) UNIQUE NOT NULL,
    FechaInicio DATE NOT NULL,
    FechaFin DATE NOT NULL
);

-- Creación de la tabla Asignaciones
CREATE TABLE Asignaciones (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    EmpleadoId INT NOT NULL,
    ProyectoId INT NOT NULL,
    FechaAsignacion DATE NOT NULL,
    CONSTRAINT fk_empleado FOREIGN KEY (EmpleadoId) REFERENCES Empleados(Id) ON DELETE CASCADE,
    CONSTRAINT fk_proyecto FOREIGN KEY (ProyectoId) REFERENCES Proyectos(Id) ON DELETE CASCADE,
    CONSTRAINT chk_unica_asignacion UNIQUE (EmpleadoId, ProyectoId)
);

-- Fase 2: Procedimientos Almacenados para Gestión de Empleados
GO

CREATE PROCEDURE RegistrarEmpleado
    @NumeroCarnet NVARCHAR(20),
    @Nombre NVARCHAR(100),
    @FechaNacimiento DATE,
    @Categoria NVARCHAR(20),
    @Salario DECIMAL(10,2),
    @Direccion NVARCHAR(255),
    @Telefono NVARCHAR(15),
    @Correo NVARCHAR(100),
    @DepartamentoId INT
AS
BEGIN
    INSERT INTO Empleados (NumeroCarnet, Nombre, FechaNacimiento, Categoria, Salario, Direccion, Telefono, Correo, DepartamentoId)
    VALUES (@NumeroCarnet, @Nombre, @FechaNacimiento, @Categoria, @Salario, ISNULL(@Direccion, 'San José'), @Telefono, @Correo, @DepartamentoId);
END
GO

CREATE PROCEDURE ListarEmpleados
AS
BEGIN
    SELECT e.*, d.Nombre AS Departamento
    FROM Empleados e
    LEFT JOIN Departamentos d ON e.DepartamentoId = d.Id;
END
GO

-- Procedimiento para actualizar rango de un empleado
  CREATE PROCEDURE ActualizarRangoEmpleado
      @EmpleadoId INT,
      @NuevoRango NVARCHAR(20)
  AS
  BEGIN
      IF @NuevoRango NOT IN ('Administrador', 'Operario', 'Peón')
      BEGIN
          RAISERROR ('El rango especificado no es válido.', 16, 1);
          RETURN;
      END
  
      UPDATE Empleados
      SET Categoria = @NuevoRango
      WHERE Id = @EmpleadoId;
  END
  GO

-- Fase 3: Procedimientos Almacenados para Gestión de Proyectos
CREATE PROCEDURE RegistrarProyecto
    @Codigo NVARCHAR(20),
    @Nombre NVARCHAR(100),
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    INSERT INTO Proyectos (Codigo, Nombre, FechaInicio, FechaFin)
    VALUES (@Codigo, @Nombre, @FechaInicio, @FechaFin);
END
GO

CREATE PROCEDURE ListarProyectos
AS
BEGIN
    SELECT * FROM Proyectos;
END
GO

-- Fase 4: Procedimientos Almacenados para Gestión de Asignaciones
CREATE PROCEDURE AsignarEmpleadoAProyecto
    @EmpleadoId INT,
    @ProyectoId INT,
    @FechaAsignacion DATE
AS
BEGIN
    INSERT INTO Asignaciones (EmpleadoId, ProyectoId, FechaAsignacion)
    VALUES (@EmpleadoId, @ProyectoId, @FechaAsignacion);
END
GO

CREATE PROCEDURE ListarAsignacionesPorProyecto
    @ProyectoId INT
AS
BEGIN
    SELECT e.Nombre, a.FechaAsignacion
    FROM Asignaciones a
    INNER JOIN Empleados e ON a.EmpleadoId = e.Id
    WHERE a.ProyectoId = @ProyectoId;
END
GO

CREATE PROCEDURE ListarProyectosPorEmpleado
    @EmpleadoId INT
AS
BEGIN
    SELECT p.Nombre, a.FechaAsignacion
    FROM Asignaciones a
    INNER JOIN Proyectos p ON a.ProyectoId = p.Id
    WHERE a.EmpleadoId = @EmpleadoId;
END
GO
