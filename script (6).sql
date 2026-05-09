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
DROP TABLE IF EXISTS sp_matricular_aluno_turma;

CREATE TABLE alunos (
    id_aluno INT PRIMARY KEY,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    nome_completo VARCHAR(200) NOT NULL,
    data_nascimento DATE NOT NULL,
	email VARCHAR(100) DEFAULT 'naoinformado@email.com',
    telefone VARCHAR(15) DEFAULT '(00) 00000-0000',
    endereco VARCHAR(300) DEFAULT 'Endereço não cadastrado',
    data_cadastro DATE NOT NULL DEFAULT (CURRENT_DATE)
);
INSERT INTO alunos (id_aluno, cpf, nome_completo, data_nascimento, email) 
VALUES (1, '12345678901', 'ALEX COELHO', '2000-12-12', 'alex@email.com'),
       (2, '12345678910', 'julia COELHO', '2008-12-12', 'julia@email.com'),
	   (3, '12345678902', 'maria COELHO', '1999-12-12', 'maria@email.com'),
       (4, '12345678903', 'mario rodrigues', '1997-12-12', 'mario@email.com'),
       (5, '12345678904', 'stevan borgues', '1198-12-12', 'stevan@email.com'),
       (6, '12345678905', 'steve john', '2008-12-12', 'steve@email.com');
    
CREATE TABLE cursos (
    id_curso INT PRIMARY KEY,
    nome_curso VARCHAR(100) NOT NULL DEFAULT 'GESTÃO DE TI',
    codigo_curso VARCHAR(20) UNIQUE,
    carga_horaria_total INT NOT NULL,
    duracao_semestres INT NOT NULL,
    modalidade VARCHAR(20) NOT NULL,
    valor_semestral DECIMAL(10,2) NOT NULL
);
    INSERT INTO cursos (id_curso, nome_curso, codigo_curso, carga_horaria_total, duracao_semestres, modalidade, valor_semestral) VALUES 
     (10, 'Gestão de Equipes', 'GE01', 40, 1, 'Presencial', 500.00),
     (20, 'Administração', 'ADM01', 3000, 8, 'Presencial', 1200.00),
     (30, 'Tomada de Decisão', 'TD01', 20, 1, 'EAD', 300.00);
     
CREATE TABLE disciplinas (
    id_disciplina INT PRIMARY KEY,
    id_curso  INT NOT NULL DEFAULT '10',
    nome_disciplina VARCHAR(100) NOT NULL,
    codigo_disciplina VARCHAR(20) UNIQUE,
    carga_horaria INT NOT NULL,
    ementa VARCHAR(1000),
    semestre_ideal INT NOT NULL,
    fk_requisito_id_disciplina INT,
    FOREIGN KEY (id_curso) REFERENCES cursos(id_curso),
    FOREIGN KEY (fk_requisito_id_disciplina) REFERENCES disciplinas(id_disciplina)
);
INSERT INTO disciplinas (id_disciplina, nome_disciplina,id_curso, codigo_disciplina, carga_horaria, semestre_ideal) VALUES 
(100, 'Gestão','10', 'LM01', '40', '5'),
(200, 'CIENCIA','20', 'EE01', '80', '5'),
(300, 'AUDITORIA','30', 'AD01', '20', '5'),
(400, 'BANCO DE DADOS','30', 'BD01', '20', '5'),
(550, 'ADMINISTRACAO DE SISTEMA','30', 'AS01', '20', '5'),
(600, 'ITINERARIO','30', 'IT01', '20', '5');

CREATE TABLE matriculas (
    id_matricula INT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_curso INT NOT NULL,
    data_matricula DATE NOT NULL DEFAULT (CURRENT_DATE), 
    periodo_ingresso VARCHAR(10) DEFAULT '2026-01-23',
    ano_ingresso INT DEFAULT 2026,                       
    status_matricula VARCHAR(20) NOT NULL DEFAULT 'ATIVO',
    FOREIGN KEY (id_aluno) REFERENCES alunos(id_aluno),
    FOREIGN KEY (id_curso) REFERENCES cursos(id_curso)
);
INSERT INTO matriculas (id_matricula,id_aluno,id_curso) VALUES 
(15,'1','10'),
(25,'2','20'),
(35,'3','30');

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
INSERT INTO turmas (id_disciplina, codigo_turma, periodo_letivo, vagas_totais,id_turma) 
VALUES 
(100, '420','100', '500', '240'),
(200, '430','200', '500', '340'),
(300, '068','201', '500', '860'),
(400, '069','201', '500', '890'),
(550, '070','201', '500', '680'),
(600, '077','201', '500', '870');

CREATE TABLE matriculas_turmas (
    id_matricula_turma INT PRIMARY KEY,
    id_matricula INT NOT NULL,
    id_turma INT NOT NULL,
    data_inscricao DATE NOT NULL DEFAULT (CURRENT_DATE),
    status_inscricao VARCHAR(20) DEFAULT 'INCRITO',
    FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula),
    FOREIGN KEY (id_turma) REFERENCES turmas(id_turma)
);
INSERT INTO matriculas_turmas (id_matricula_turma,id_matricula,id_turma) 
VALUES 
(110, '15','240'),
(220, '25','340'),
(333, '35','860');

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

CREATE TABLE log_atividades (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    tabela_afetada VARCHAR(50),
    tipo_operacao VARCHAR(20),
    data_hora DATETIME,
    detalhes TEXT
);



CREATE OR REPLACE VIEW v_resumo_academico AS
SELECT 
    a.nome_completo AS 'Nome do Aluno',
    c.nome_curso AS 'Curso',
    m.status_matricula AS 'Status da Matrícula',
    t.codigo_turma AS 'Turma',
    d.nome_disciplina AS 'Disciplina'
FROM alunos a
LEFT JOIN matriculas m ON a.id_aluno = m.id_aluno
LEFT JOIN cursos c ON m.id_curso = c.id_curso
LEFT JOIN matriculas_turmas mt ON m.id_matricula = mt.id_matricula
LEFT JOIN turmas t ON mt.id_turma = t.id_turma
LEFT JOIN disciplinas d ON t.id_disciplina = d.id_disciplina;

DROP PROCEDURE IF EXISTS sp_matricular_aluno_turma;
DELIMITER //
CREATE PROCEDURE sp_matricular_aluno_turma (
    IN p_id_matricula_turma INT,
    IN p_id_matricula INT,
    IN p_id_turma INT
)
BEGIN
    INSERT INTO matriculas_turmas (id_matricula_turma, id_matricula, id_turma, data_inscricao, status_inscricao)
    VALUES (p_id_matricula_turma, p_id_matricula, p_id_turma, CURDATE(), 'ATIVO');
    
    UPDATE turmas 
    SET vagas_ocupadas = vagas_ocupadas + 1 
    WHERE id_turma = p_id_turma;
END //

CREATE TRIGGER tr_log_update_aluno
AFTER UPDATE ON alunos
FOR EACH ROW
BEGIN
    INSERT INTO log_atividades (tabela_afetada, tipo_operacao, data_hora, detalhes)
    VALUES ('alunos', 'UPDATE', NOW(), CONCAT('Aluno ID: ', OLD.id_aluno, ' Nome anterior: ', OLD.nome_completo));
END //

CREATE TRIGGER tr_log_delete_aluno
BEFORE DELETE ON alunos
FOR EACH ROW
BEGIN
    INSERT INTO log_atividades (tabela_afetada, tipo_operacao, data_hora, detalhes)
    VALUES ('alunos', 'DELETE', NOW(), CONCAT('Removido aluno: ', OLD.nome_completo, ' CPF: ', OLD.cpf));
END //

CREATE TRIGGER tr_log_insert_aluno
AFTER INSERT ON alunos
FOR EACH ROW
BEGIN
    INSERT INTO log_atividades (tabela_afetada, tipo_operacao, data_hora, detalhes)
    VALUES ('alunos', 'INSERT', NOW(), CONCAT('Novo aluno cadastrado: ', NEW.nome_completo));
END //


DELIMITER ;
SELECT * FROM v_resumo_academico;
SELECT * FROM alunos;
SELECT * FROM log_atividades;
SELECT * FROM cursos;
SELECT * FROM disciplinas;
SELECT * FROM matriculas;
SELECT * FROM matriculas_turmas;
SELECT * FROM turmas