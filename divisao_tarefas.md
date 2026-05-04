## 👥 Divisão de Tarefas (Grupo)

### 👤 Pessoa 1 — Scanner (Flex)
- [ ] Definir tokens da linguagem (números, identificadores, operadores, parênteses)
- [ ] Implementar regras no arquivo `.l`
- [ ] Testar reconhecimento de tokens
- [ ] Tratar erros léxicos
- [ ] Integrar saída de tokens com o parser

---

### 👤 Pessoa 2 — Parser (Bison)
- [ ] Definir gramática da linguagem
- [ ] Implementar regras no arquivo `.y`
- [ ] Construir AST (Árvore Sintática)
- [ ] Resolver conflitos (shift/reduce, reduce/reduce)
- [ ] Integrar com o scanner

---

### 👤 Pessoa 3 — Semântica + Geração de Código
- [ ] Implementar tabela de símbolos
- [ ] Verificar declaração e uso de variáveis
- [ ] Validar tipos (ex: número vs string)
- [ ] Implementar controle de escopo
- [ ] Traduzir AST para código Python
- [ ] Gerar saída final (`.py`)

---

## 🔄 Tarefas em Conjunto
- [ ] Definir escopo do projeto (subconjunto de Scheme)
- [ ] Criar casos de teste (válidos e inválidos)
- [ ] Integrar todas as etapas (scanner → parser → semântica → código)
- [ ] Criar Makefile
- [ ] Testar execução completa
- [ ] Escrever relatório final

---

## 📌 Observações
- [ ] Revisão geral do código
- [ ] Padronização (nomes, estrutura)
- [ ] Preparação para entrega