-- Criando a tabela Produtos
CREATE TABLE Produtos (
    ProdutoID INT PRIMARY KEY,
    Nome NVARCHAR(100),
    Preco DECIMAL(10, 2)
);

-- Inserindo alguns dados na tabela
INSERT INTO Produtos (ProdutoID, Nome, Preco)
VALUES
(1, 'Produto A', 10.50),
(2, 'Produto B', 20.75);

-- Sessão 1
BEGIN TRANSACTION;

-- Atualizando o preço do Produto A
UPDATE Produtos
SET Preco = 15.00
WHERE ProdutoID = 1;

-- Sessão 2
UPDATE Produtos
SET Preco = 18.00
WHERE ProdutoID = 1;

-- Sessão 1
COMMIT TRANSACTION;  -- Ou ROLLBACK TRANSACTION, se quiser desfazer a alteração
