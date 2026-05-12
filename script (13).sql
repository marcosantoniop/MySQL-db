-- 1. PREPARAÇÃO DO AMBIENTE
-- Derrubamos o banco antigo se existir e crio um novo para começarmos do zero.
DROP DATABASE IF EXISTS sistema_academico;
CREATE DATABASE IF NOT EXISTS sistema_academico;
USE sistema_academico;

-- Removemos as tabelas na ordem inversa das chaves estrangeiras para evitar erros de restrição (constraints).
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


-- 2. CADASTROS BÁSICOS (CORE ACADÊMICO)
-- Tabela de alunos com valores padrão para evitar dados nulos de contato.
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

-- Populamos a tabela de alunos com alguns registros de teste.
INSERT INTO alunos (id_aluno, cpf, nome_completo, data_nascimento, email) 
VALUES (1, '94170488059', 'Alex Telles', '1992-12-15', 'alex@email.com'),
       (2, '34310042023', 'Julia Coelho', '2008-10-5', 'julia@email.com'),
	   (3, '28317840000', 'Maria Antonieta', '1975-11-2', 'maria@email.com'),
       (4, '79175514079', 'Mario Gomes', '1997-12-25', 'mario@email.com'),
       (5, '86865557808', 'Stevan Borgues', '1998-12-12', 'stevan@email.com'),
       (6, '50325330840', 'Steve Jobs', '1955-2-24', 'steve@email.com');

-- Cadastro dos cursos, definindo a modalidade e o valor base do semestre.
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
     (10, 'Gestão de Equipes', 'GE01', 40, 3, 'Presencial', 550.00),
     (20, 'Administração', 'ADM01', 80, 8, 'Presencial', 1000.00),
     (30, 'Tomada de Decisão', 'TD01', 20, 2, 'EAD', 400.00),
     (40, 'Gestão de TI2', 'GTI02', 30, 4, 'EAD', 300.00),
     (50, 'Administração2', 'ADM02', 50, 3, 'EAD', 500.00),
     (60, 'Tomada de Decisão2', 'TD02', 60, 4, 'EAD', 450.00);
     
-- Disciplinas que compõem os cursos. Adicionamos um auto-relacionamento (fk_requisito) para trancar matérias.
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
(200, 'Ciência','20', 'EE01', '80', '4'),
(300, 'Auditoria','30', 'AD01', '20', '1'),
(400, 'Banco de Dados','40', 'BD01', '40', '2'),
(550, 'Administração de Sistema','50', 'AS01', '20', '2'),
(600, 'Itinerário','60', 'IT01', '60', '6');

-- O vínculo central: Aluno matriculado no curso.
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
(35,'3','30'),
(52,'4','40'),
(65,'5','50'),
(73,'6','60');

-- Oferta das disciplinas em turmas específicas.
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

-- Enturmação: Onde o aluno matriculado escolhe as turmas para cursar.
CREATE TABLE matriculas_turmas (
    id_matricula_turma INT PRIMARY KEY,
    id_matricula INT NOT NULL,
    id_turma INT NOT NULL,
    data_inscricao DATE NOT NULL DEFAULT (CURRENT_DATE),
    status_inscricao VARCHAR(20) DEFAULT 'INSCRITO',
    FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula),
    FOREIGN KEY (id_turma) REFERENCES turmas(id_turma)
);
INSERT INTO matriculas_turmas (id_matricula_turma,id_matricula,id_turma) 
VALUES 
(110, '15','240'),
(220, '25','340'),
(333, '35','860'),
(250, '52','890'),
(240, '65','680'),
(267, '73','870');

-- Tabelas acessórias para notas e controle de presença.
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


-- 3. MÓDULO FINANCEIRO
-- O contrato é gerado no ato da matrícula.
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
INSERT INTO contratos_educacionais (id_contrato,id_matricula,numero_contrato,data_contrato,valor_total,quantidade_parcelas,dia_vencimento,status_contrato) 
VALUES 
(002, '15','240','2008-12-12', '1500','1', '15','ativo'),
(003, '25','340','2009-2-25', '1500','2', '15','ativo'),
(004, '35','860','2010-10-3', '1500','3', '15','ativo'),
(005, '52','890','2011-9-5', '1500','4', '15','ativo'),
(006, '65','680','2012-4-18', '1500','5', '15','ativo'),
(007, '73','870','2013-2-21', '1500','6', '15','ativo');

-- O contrato se desdobra em mensalidades (as parcelas a pagar).
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
INSERT INTO mensalidades (id_mensalidade,id_contrato,numero_parcela,data_vencimento,valor_original,valor_com_desconto,valor_com_juros,status_mensalidade) 
VALUES 
(111, '002','1','2008-12-25', '5000','4000', '15','PAGO'),
(222, '003','2','2008-10-20', '5000','4200', '15','PAGO'),
(334, '004','3','2008-5-3', '5000','4400', '15','PAGO'),
(444, '005','4','2008-4-8', '5000','4600', '15','PAGO'),
(555, '006','5','2008-1-5', '5000','4800', '15','PAGO'),
(666, '007','6','2008-8-14', '5000','5000', '15','PAGO');

-- Tabela de transações reais. Uso o CHECK para barrar valores negativos no banco.
CREATE TABLE pagamentos (
    id_pagamento INT PRIMARY KEY,
    id_mensalidade INT NOT NULL,
    data_pagamento DATE,
    valor_pago DECIMAL(10,2) CHECK (valor_pago >= 0),
    forma_pagamento VARCHAR(30),
    comprovante VARCHAR(100),
    FOREIGN KEY (id_mensalidade) REFERENCES mensalidades(id_mensalidade)
);
INSERT INTO pagamentos (id_pagamento,id_mensalidade,data_pagamento,valor_pago,forma_pagamento,comprovante) 
VALUES 
(110, '111','2008-10-15','2500', 'CREDITO','RECIBO-001'),
(220, '222','2015-11-25','2500', 'CREDITO','RECIBO-002'),
(333, '334','2006-8-20','2500', 'CREDITO','RECIBO-003'),
(250, '444','2020-9-10','2500', 'CREDITO','RECIBO-004'),
(240, '555','2022-7-7','2500', 'CREDITO','RECIBO-005'),
(267, '666','2009-1-8','2500', 'CREDITO','RECIBO-006');


-- Controle para os alunos que atrasam.
CREATE TABLE inadimplencia (
    id_inadimplencia INT PRIMARY KEY,
    id_mensalidade INT NOT NULL,
    dias_atraso INT,
    valor_devido DECIMAL(10,2),
    data_registro DATE,
    status_cobranca VARCHAR(30),
    FOREIGN KEY (id_mensalidade) REFERENCES mensalidades(id_mensalidade)
);

-- 4. RECURSOS HUMANOS
-- Gestão dos colaboradores da instituição.
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

-- Especialização da tabela funcionários para o corpo docente.
CREATE TABLE professores (
    id_professor INT PRIMARY KEY,
    id_funcionario INT NOT NULL,
    titulacao VARCHAR(30),
    area_especializacao VARCHAR(100),
    carga_horaria_semanal INT,
    regime_trabalho VARCHAR(20),
    FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario)
);

-- Alocação do professor para ministrar a turma.
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


-- 5. AUDITORIA E SEGURANÇA
-- Tabela vital para registrar tudo o que acontece no sistema (logs imutáveis na aplicação).
CREATE TABLE log_atividades (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    tabela_afetada VARCHAR(50),
    tipo_operacao VARCHAR(20),
    data_hora DATETIME,
    detalhes TEXT
);

-- 6. VIEWS DE CONSOLIDAÇÃO
-- Criamos essas visões para facilitar a vida do front-end e evitar joins complexos toda hora.

-- View com o panorama acadêmico do aluno.
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

-- View com a vida financeira completa (com uso de window functions para totalizadores).
CREATE OR REPLACE VIEW v_resumo_financeiro AS
SELECT 
    m.id_mensalidade,
    c.id_matricula,
    a.nome_completo AS nome_aluno,
    m.numero_parcela,
    m.data_vencimento,
    m.valor_original,
    m.status_mensalidade,
    p.id_pagamento,
    p.data_pagamento,
    COALESCE(p.valor_pago, 0) AS valor_pago,
    p.forma_pagamento,
    
    SUM(COALESCE(p.valor_pago, 0)) OVER(PARTITION BY a.id_aluno) AS total_pago_pelo_aluno,
    
    SUM(m.valor_original) OVER(PARTITION BY a.id_aluno) AS valor_total_contratado_aluno
   
    
FROM mensalidades m
INNER JOIN contratos_educacionais c ON m.id_contrato = c.id_contrato
INNER JOIN matriculas ma ON c.id_matricula = ma.id_matricula
INNER JOIN alunos a ON ma.id_aluno = a.id_aluno
LEFT JOIN pagamentos p ON m.id_mensalidade = p.id_mensalidade;



-- 7. PROCEDURES E REGRAS DE NEGÓCIO
DROP PROCEDURE IF EXISTS sp_matricular_aluno_turma;
DROP PROCEDURE IF EXISTS sp_registrar_pagamento;

-- Automatiza a enturmação e garante que a vaga ocupada seja incrementada na turma.
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

-- 8. GATILHOS (TRIGGERS) DE AUDITORIA

-- Bloco de log para a tabela ALUNOS
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
DELIMITER //

-- Procedure transacional para garantir que o pagamento dê baixa na mensalidade correta.
-- Em caso de erro em qualquer parte, daremos Rollback para proteger o banco.
CREATE PROCEDURE sp_registrar_pagamento (
    IN p_id_pagamento INT,
    IN p_id_mensalidade INT,
    IN p_valor_pago DECIMAL(10,2),
    IN p_forma_pagamento VARCHAR(30),
    IN p_comprovante VARCHAR(100)
)
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
    END;
    
    START TRANSACTION;
    
    INSERT INTO pagamentos (id_pagamento, id_mensalidade, data_pagamento, valor_pago, forma_pagamento, comprovante)
    VALUES (p_id_pagamento, p_id_mensalidade, CURDATE(), p_valor_pago, p_forma_pagamento, p_comprovante);
    
   
    UPDATE mensalidades 
    SET status_mensalidade = 'PAGO' 
    WHERE id_mensalidade = p_id_mensalidade;
    
    COMMIT;
END //

DELIMITER ;
DELIMITER //

-- Bloco de log para a tabela MENSALIDADES
CREATE TRIGGER tr_log_insert_mensalidade
AFTER INSERT ON mensalidades
FOR EACH ROW
BEGIN
    INSERT INTO log_atividades (tabela_afetada, tipo_operacao, data_hora, detalhes)
    VALUES ('mensalidades', 'INSERT', NOW(), 
    CONCAT('Nova mensalidade gerada - ID: ', NEW.id_mensalidade, 
           ', Contrato: ', NEW.id_contrato, 
           ', Parcela: ', NEW.numero_parcela, 
           ', Valor: R$', NEW.valor_original));
END //


CREATE TRIGGER tr_log_update_mensalidade
AFTER UPDATE ON mensalidades
FOR EACH ROW
BEGIN
    INSERT INTO log_atividades (tabela_afetada, tipo_operacao, data_hora, detalhes)
    VALUES ('mensalidades', 'UPDATE', NOW(), 
    CONCAT('Alteração na mensalidade ID: ', OLD.id_mensalidade, 
           ' - Status anterior: ', OLD.status_mensalidade, 
           ' -> Novo status: ', NEW.status_mensalidade));
END //


CREATE TRIGGER tr_log_delete_mensalidade
BEFORE DELETE ON mensalidades
FOR EACH ROW
BEGIN
    INSERT INTO log_atividades (tabela_afetada, tipo_operacao, data_hora, detalhes)
    VALUES ('mensalidades', 'DELETE', NOW(), 
    CONCAT('Removida mensalidade ID: ', OLD.id_mensalidade, 
           ' do Contrato: ', OLD.id_contrato, 
           ' (Valor era: R$', OLD.valor_original, ')'));
END //

-- Bloco de log para a tabela PAGAMENTOS (crítico)
CREATE TRIGGER tr_log_insert_pagamento
AFTER INSERT ON pagamentos
FOR EACH ROW
BEGIN
    INSERT INTO log_atividades (tabela_afetada, tipo_operacao, data_hora, detalhes)
    VALUES ('pagamentos', 'INSERT', NOW(), 
    CONCAT('Pagamento registrado - ID: ', NEW.id_pagamento, 
           ', Mensalidade Ref: ', NEW.id_mensalidade, 
           ', Valor Pago: R$', NEW.valor_pago, 
           ', Forma: ', NEW.forma_pagamento));
END //


CREATE TRIGGER tr_log_update_pagamento
AFTER UPDATE ON pagamentos
FOR EACH ROW
BEGIN
    INSERT INTO log_atividades (tabela_afetada, tipo_operacao, data_hora, detalhes)
    VALUES ('pagamentos', 'UPDATE', NOW(), 
    CONCAT('Atualização no pagamento ID: ', OLD.id_pagamento, 
           ' - Valor anterior: R$', OLD.valor_pago, 
           ' -> Novo valor: R$', NEW.valor_pago));
END //


CREATE TRIGGER tr_log_delete_pagamento
BEFORE DELETE ON pagamentos
FOR EACH ROW
BEGIN
    INSERT INTO log_atividades (tabela_afetada, tipo_operacao, data_hora, detalhes)
    VALUES ('pagamentos', 'DELETE', NOW(), 
    CONCAT('ESTORNO/EXCLUSÃO de pagamento - ID: ', OLD.id_pagamento, 
           ', Mensalidade Ref: ', OLD.id_mensalidade, 
           ', Valor removido: R$', OLD.valor_pago));
END //

DELIMITER ;

-- 9. QUERIES DE VERIFICAÇÃO RÁPIDA (SANITY CHECKS)
SELECT COUNT(*) AS total_alunos FROM alunos;
SELECT COUNT(*) AS total_cursos FROM cursos;
SELECT COUNT(*) AS total_disciplina FROM disciplinas; 
SELECT COUNT(*) AS total_matriculas FROM matriculas;
SELECT COUNT(*) AS total_turmas FROM turmas;
SELECT COUNT(*) AS total_matriculas_turmas FROM matriculas_turmas;
SELECT COUNT(*) AS total_contratos FROM contratos_educacionais;
SELECT COUNT(*) AS total_mensalidades FROM mensalidades;
SELECT COUNT(*) AS total_pagamentos FROM pagamentos;
SELECT COUNT(*) AS total_funcionarios FROM funcionarios;
SELECT COUNT(*) AS total_professores FROM professores;
SELECT COUNT(*) AS total_logs FROM log_atividades;

SELECT * FROM log_atividades;
SELECT * FROM v_resumo_academico;
SELECT * FROM v_resumo_financeiro;
SELECT * FROM alunos;
SELECT * FROM cursos;
SELECT * FROM disciplinas;
SELECT * FROM matriculas;
SELECT * FROM matriculas_turmas;
SELECT * FROM turmas;
SELECT * FROM pagamentos;
SELECT * FROM mensalidades;
SELECT * FROM contratos_educacionais;

-- ==============================================================================
-- 10. MODELAGEM DIMENSIONAL PARA BI (DATA WAREHOUSE / OLAP)
-- Criamos um Star Schema focado em analisar os pagamentos ao longo do tempo e cursos.
-- ==============================================================================
DROP TABLE IF EXISTS fato_pagamentos;
DROP TABLE IF EXISTS dim_tempo;
DROP TABLE IF EXISTS dim_curso;
DROP TABLE IF EXISTS dim_aluno;

-- Dimensão de Alunos (Guarda o contexto de quem paga)
CREATE TABLE dim_aluno (
    sk_aluno INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT,
    nome_completo VARCHAR(200)
);

-- Dimensão de Cursos (Guarda o contexto do que está rendendo)
CREATE TABLE dim_curso (
    sk_curso INT AUTO_INCREMENT PRIMARY KEY,
    id_curso INT,
    nome_curso VARCHAR(100),
    modalidade VARCHAR(20)
);

-- Dimensão de Tempo (Facilita agregações por mês, ano, etc.)
CREATE TABLE dim_tempo (
    sk_tempo INT AUTO_INCREMENT PRIMARY KEY,
    data_completa DATE,
    ano INT,
    mes INT,
    dia INT
);

-- Tabela Fato: O centro da estrela, onde ficam as métricas (valor_pago)
CREATE TABLE fato_pagamentos (
    sk_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    sk_aluno INT,
    sk_curso INT,
    sk_tempo INT,
    valor_pago DECIMAL(10,2),

    FOREIGN KEY (sk_aluno) REFERENCES dim_aluno(sk_aluno),
    FOREIGN KEY (sk_curso) REFERENCES dim_curso(sk_curso),
    FOREIGN KEY (sk_tempo) REFERENCES dim_tempo(sk_tempo)
);

-- 11. ETL: EXTRAÇÃO, TRANSFORMAÇÃO E CARGA
-- Populamos a Dimensão Aluno com os dados do OLTP
INSERT INTO dim_aluno (id_aluno, nome_completo)
SELECT id_aluno, nome_completo
FROM alunos;

-- Populamos a dimensão Curso
INSERT INTO dim_curso (id_curso, nome_curso, modalidade)
SELECT id_curso, nome_curso, modalidade
FROM cursos;

-- Populamos as datas únicas vindas dos pagamentos
INSERT INTO dim_tempo (data_completa, ano, mes, dia)
SELECT DISTINCT
    data_pagamento,
    YEAR(data_pagamento),
    MONTH(data_pagamento),
    DAY(data_pagamento)
FROM pagamentos
WHERE data_pagamento IS NOT NULL;

-- Carga da Fato cruzando todas as chaves (Surrogate Keys)
INSERT INTO fato_pagamentos (
    sk_aluno,
    sk_curso,
    sk_tempo,
    valor_pago
)

SELECT
    da.sk_aluno,
    dc.sk_curso,
    dt.sk_tempo,
    p.valor_pago

FROM pagamentos p

JOIN mensalidades me
    ON p.id_mensalidade = me.id_mensalidade

JOIN contratos_educacionais ce
    ON me.id_contrato = ce.id_contrato

JOIN matriculas m
    ON ce.id_matricula = m.id_matricula

JOIN dim_aluno da
    ON m.id_aluno = da.id_aluno

JOIN dim_curso dc
    ON m.id_curso = dc.id_curso

JOIN dim_tempo dt
    ON p.data_pagamento = dt.data_completa;

-- 12. CONSULTAS ANALÍTICAS (OLAP) PARA BI
SELECT COUNT(*) AS total_fato_pagamentos
FROM fato_pagamentos;

-- Validação de reconciliação de valores: OLTP vs OLAP tem que bater.
SELECT SUM(valor_pago) AS total_oltp
FROM pagamentos;

SELECT SUM(valor_pago) AS total_olap
FROM fato_pagamentos;

-- Receita total agrupada por curso.
SELECT 
    dc.nome_curso,
    SUM(fp.valor_pago) AS total_pago
FROM fato_pagamentos fp
JOIN dim_curso dc
    ON fp.sk_curso = dc.sk_curso
GROUP BY dc.nome_curso;

-- Análise temporal de receita (Agrupado por mês).
SELECT
    dt.mes,
    SUM(fp.valor_pago) AS receita_mes
FROM fato_pagamentos fp
JOIN dim_tempo dt
    ON fp.sk_tempo = dt.sk_tempo
GROUP BY dt.mes
ORDER BY dt.mes;

-- Contagem de quantos pagamentos cada curso recebeu.
SELECT
    dc.nome_curso,
    COUNT(fp.sk_pagamento) AS quantidade_pagamentos
FROM fato_pagamentos fp
JOIN dim_curso dc
    ON fp.sk_curso = dc.sk_curso
GROUP BY dc.nome_curso;


-- 13. OTIMIZAÇÃO (ÍNDICES) E DIAGNÓSTICO
-- Criamos índices nas colunas que usamos mais no WHERE e nos JOINs para melhorar a performance.
CREATE INDEX idx_pagamentos_data 
ON pagamentos(data_pagamento);

CREATE INDEX idx_pagamentos_mensalidade 
ON pagamentos(id_mensalidade);

CREATE INDEX idx_matriculas_aluno 
ON matriculas(id_aluno);

CREATE INDEX idx_matriculas_curso 
ON matriculas(id_curso);

-- Explicamos o plano de execução dessa query para validar se os índices estão sendo usados.
EXPLAIN
SELECT *
FROM pagamentos
WHERE data_pagamento IS NOT NULL;



