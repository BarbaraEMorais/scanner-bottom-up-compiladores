## 👥 Divisão de Tarefas (Grupo)

### 👤 Cael — Scanner (Flex)
- [x] Definir tokens da linguagem (números, identificadores, operadores, parênteses)
- [ ] Passar regras para `definitions.l`  
- [ ] Ver se reconhecimento de tokens está funcionando
- [ ] Tratar erros léxicos 
- [ ] Integrar saída de tokens com o parser**

---

### 👤 João + Bárbara — Parser (Bison)
- [ ] Definir gramática da linguagem [J]
- [ ] Implementar regras no arquivo `.y` [J]
- [ ] Construir AST (Árvore Sintática) [B]
- [ ] Resolver conflitos (shift/reduce, reduce/reduce) 
- [ ] Integrar com o scanner [J]

---

### 👤 Geral — Semântica + Geração de Código
- [ ] Fazer tratativa de erros final
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

---

## 📌 Observações
- [ ] Revisão geral do código
- [ ] Padronização (nomes, estrutura)
- [ ] Preparação para entrega
