## 🧩 Etapas do Projeto

### 1. Scanner (Análise Léxica)
- **Ferramenta:** Flex  
- **Função:** Ler o código e gerar tokens (números, identificadores, operadores, parênteses)

---

### 2. Parser Bottom-Up (Análise Sintática)
- **Ferramenta:** Bison  
- **Função:** Receber tokens, validar a gramática e gerar a AST  
- **Tipo:** Bottom-up (shift-reduce)

---

### 3. Verificação Semântica
- **Função:** Garantir uso correto de variáveis, tipos e escopo  
- **Regras:** Variáveis devem ser declaradas e tipos compatíveis  
- **Estruturas:** Tabela de símbolos e controle de escopo  

---

### 4. Geração de Código (Scheme → Python)
- **Função:** Traduzir Scheme para Python  
- **Estratégia:** Preferencialmente gerar AST e depois converter  

---

## 🛠️ Tecnologias Obrigatórias
- Flex (scanner)  
- Bison (parser)  

**Linguagens:** C, C++ ou Java  

---

## 📦 Entregáveis
1. Código fonte (.l, .y e auxiliares)  
2. Execução (Makefile)  
3. Testes (válidos e com erro)  
4. Relatório (funcionalidades, limitações, divisão)  

---

## ⚠️ Escopo
Implementar apenas um subconjunto:
- `define`
- Operações aritméticas
- `if`
- Expressões simples
- Funções básicas  

---

## 🔧 Estrutura
- Scanner: tokens  
- Parser: regras sintáticas  
- Semântica: tabela de símbolos + tipos  
- Código: tradução para Python  

---

## 🧭 Fluxo
Scheme → Scanner → Tokens → Parser → AST → Semântica → Python  

---

## ✅ Resumo
Compilador que lê Scheme, analisa com Flex+Bison, valida e gera Python.

---