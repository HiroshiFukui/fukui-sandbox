# Relatório de Atualização: AI Sandbox Architect - v0.2.0

## 1. Visão Geral
Esta atualização marca a transição para a versão **v0.2.0** do framework AI Sandbox Architect, introduzindo suporte nativo para **Dev Containers** do VS Code e suporte a documentação multi-idioma.

- **Data da Atualização:** 13 de Maio de 2026
- **Status:** Disponível

---

## 2. Principais Novidades

### 2.1 Suporte a Dev Containers
O skill `sa-create-ai-sandbox` foi expandido para suportar o runtime `devcontainer`. Isso permite que desenvolvedores abram suas sandboxes diretamente no VS Code com todas as ferramentas e extensões pré-configuradas.

**Arquivos gerados no modo Dev Container:**
- `.devcontainer/devcontainer.json`
- `.devcontainer/docker-compose.yml`
- `.devcontainer/Dockerfile`
- `.env.example`
- `README.md`

### 2.2 Documentação Localizada (Português)
O skill `sa-document-ai-sandbox` agora suporta templates em português. Foi adicionado o template `assets/documentation_pt.md.template` que gera documentação técnica completa em português, incluindo seções específicas para o uso de Dev Containers.

### 2.3 Melhorias nos Workflows
- **Discovery:** Agora pergunta explicitamente pelo `Target Runtime` (docker-compose, devcontainer ou ambos).
- **Handoff:** Instruções claras sobre como iniciar a sandbox, seja via terminal ou via VS Code.

---

## 3. Como Usar

### 3.1 Criando uma Sandbox com Dev Container
Ao utilizar o skill `sa-create-ai-sandbox`, selecione `devcontainer` ou `both` quando solicitado sobre o runtime.

### 3.2 Gerando Documentação em Português
Para gerar a documentação em português para uma sandbox existente, configure o parâmetro `doc_template` para `assets/documentation_pt.md.template` no workflow do skill `sa-document-ai-sandbox`.

---

## 4. Próximos Passos
- Integração com ferramentas de monitoramento em tempo real.
- Expansão da biblioteca de Blueprints para modelos locais (Ollama/LocalAI).

---
*Documento gerado automaticamente pelo BMad Sandbox Documentarian.*
