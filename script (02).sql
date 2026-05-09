CREATE DATABASE IF NOT EXISTS sistema_academico;
USE sistema_academico;

DROP TABLE IF EXISTS log_atividades;
DROP TABLE IF EXISTS vinculos_professor_disciplina;
DROP TABLE IF EXISTS professores;
DROP TABLE IF EXISTS funcionarios;
DROP TABLE IF EXISTS inadimplencia;
DROP TABLE IF EXISTS pagamentos;
DROP TABLE IF EXISTS mensalidades;
DROP TABLE IF EXISTS contratos_educacionais;
DROP TABLE IF EXISTS faltas;
DROP TABLE IF EXISTS notas;
DROP TABLE IF EXISTS matriculas_turmas;
DROP TABLE IF EXISTS turmas;
DROP TABLE IF EXISTS matriculas;
DROP TABLE IF EXISTS disciplinas;
DROP TABLE IF EXISTS cursos;
DROP TABLE IF EXISTS alunos;

-- Criação das Tabelas Originais
CREATE TABLE alunos (
    id_aluno INT PRIMARY KEY,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    nome_completo VARCHAR(200) NOT NULL,
    data_nascimento DATE NOT NULL,
    email VARCHAR(100),
    telefone VARCHAR(15),
    endereco VARCHAR(300),
    data_cadastro DATE NOT NULL
);

CREATE TABLE cursos (
    id_curso INT PRIMARY KEY,
    nome_curso VARCHAR(100) NOT NULL,
    codigo_curso VARCHAR(20) UNIQUE,
    carga_horaria_total INT NOT NULL,
    duracao_semestres INT NOT NULL,
    modalidade VARCHAR(20) NOT NULL,
    valor_semestral DECIMAL(10,2) NOT NULL
);

CREATE TABLE disciplinas (
    id_disciplina INT PRIMARY KEY,
    id_curso INT NOT NULL,
    nome_disciplina VARCHAR(100) NOT NULL,
    codigo_disciplina VARCHAR(20) UNIQUE,
    carga_horaria INT NOT NULL,
    ementa VARCHAR(1000),
    semestre_ideal INT NOT NULL,
    fk_requisito_id_disciplina INT,
    FOREIGN KEY (id_curso) REFERENCES cursos(id_curso),
    FOREIGN KEY (fk_requisito_id_disciplina) REFERENCES disciplinas(id_disciplina)
);

CREATE TABLE matriculas (
    id_matricula INT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_curso INT NOT NULL,
    data_matricula DATE NOT NULL,
    periodo_ingresso VARCHAR(10),
    ano_ingresso INT,
    status_matricula VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_aluno) REFERENCES alunos(id_aluno),
    FOREIGN KEY (id_curso) REFERENCES cursos(id_curso)
);

CREATE TABLE turmas (
    id_turma INT PRIMARY KEY,
    id_disciplina INT NOT NULL,
    codigo_turma VARCHAR(20) UNIQUE,
    periodo_letivo VARCHAR(10),
    ano_letivo INT,
    horario VARCHAR(50),
    sala VARCHAR(20),
    vagas_totais INT,
    vagas_ocupadas INT DEFAULT 0,
    FOREIGN KEY (id_disciplina) REFERENCES disciplinas(id_disciplina)
);

CREATE TABLE matriculas_turmas (
    id_matricula_turma INT PRIMARY KEY,
    id_matricula INT NOT NULL,
    id_turma INT NOT NULL,
    data_inscricao DATE,
    status_inscricao VARCHAR(20),
    FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula),
    FOREIGN KEY (id_turma) REFERENCES turmas(id_turma)
);

CREATE TABLE notas (
    id_nota INT PRIMARY KEY,
    id_matricula_turma INT NOT NULL,
    tipo_avaliacao VARCHAR(20),
    valor_nota DECIMAL(4,2) CHECK (valor_nota BETWEEN 0 AND 10),
    data_lancamento DATE,
    FOREIGN KEY (id_matricula_turma) REFERENCES matriculas_turmas(id_matricula_turma)
);

CREATE TABLE faltas (
    id_falta INT PRIMARY KEY,
    id_matricula_turma INT NOT NULL,
    data_aula DATE,
    quantidade_faltas INT,
    justificada VARCHAR(3),
    FOREIGN KEY (id_matricula_turma) REFERENCES matriculas_turmas(id_matricula_turma)
);

CREATE TABLE contratos_educacionais (
    id_contrato INT PRIMARY KEY,
    id_matricula INT NOT NULL,
    numero_contrato VARCHAR(30),
    data_contrato DATE,
    valor_total DECIMAL(10,2),
    quantidade_parcelas INT,
    dia_vencimento INT,
    status_contrato VARCHAR(20),
    FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula)
);

CREATE TABLE mensalidades (
    id_mensalidade INT PRIMARY KEY,
    id_contrato INT NOT NULL,
    numero_parcela INT,
    data_vencimento DATE,
    valor_original DECIMAL(10,2),
    valor_com_desconto DECIMAL(10,2),
    valor_com_juros DECIMAL(10,2),
    status_mensalidade VARCHAR(20),
    FOREIGN KEY (id_contrato) REFERENCES contratos_educacionais(id_contrato)
);

CREATE TABLE pagamentos (
    id_pagamento INT PRIMARY KEY,
    id_mensalidade INT NOT NULL,
    data_pagamento DATE,
    valor_pago DECIMAL(10,2) CHECK (valor_pago >= 0),
    forma_pagamento VARCHAR(30),
    comprovante VARCHAR(100),
    FOREIGN KEY (id_mensalidade) REFERENCES mensalidades(id_mensalidade)
);

CREATE TABLE inadimplencia (
    id_inadimplencia INT PRIMARY KEY,
    id_mensalidade INT NOT NULL,
    dias_atraso INT,
    valor_devio DECIMAL(10,2),
    data_registro DATE,
    status_cobranca VARCHAR(30),
    FOREIGN KEY (id_mensalidade) REFERENCES mensalidades(id_mensalidade)
);

CREATE TABLE funcionarios (
    id_funcionario INT PRIMARY KEY,
    cpf VARCHAR(11) UNIQUE,
    nome_completo VARCHAR(200),
    data_nascimento DATE,
    email VARCHAR(100),
    telefone VARCHAR(15),
    cargo VARCHAR(50),
    departamento VARCHAR(50),
    data_admissao DATE,
    salario DECIMAL(10,2),
    status_funcionario VARCHAR(20)
);

CREATE TABLE professores (
    id_professor INT PRIMARY KEY,
    id_funcionario INT NOT NULL,
    titulacao VARCHAR(30),
    area_especializacao VARCHAR(100),
    carga_horaria_semanal INT,
    regime_trabalho VARCHAR(20),
    FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario)
);

CREATE TABLE vinculos_professor_disciplina (
    id_vinculo INT PRIMARY KEY,
    id_professor INT NOT NULL,
    id_turma INT NOT NULL,
    data_inicio DATE,
    data_fim DATE,
    carga_horaria_alocada INT,
    FOREIGN KEY (id_professor) REFERENCES professores(id_professor),
    FOREIGN KEY (id_turma) REFERENCES turmas(id_turma)
);

-- Tabela Auxiliar para Logs (necessária para os Triggers)
CREATE TABLE log_atividades (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    tabela_afetada VARCHAR(50),
    tipo_operacao VARCHAR(20),
    data_hora DATETIME,
    detalhes TEXT
);
