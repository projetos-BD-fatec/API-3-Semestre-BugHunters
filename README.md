# 📌 DataMed - Sua saúde, sem complicação.

Este é o **repositório principal e centralizador** do projeto (Equipe BugHunters). Ele é dedicado à documentação oficial, regras de negócio, acompanhamento das Sprints (Scrum) e gestão da arquitetura baseada em submódulos.

Para visualizar o código-fonte da aplicação, acesse os repositórios específicos abaixo:

[![Repositório Front-end](https://img.shields.io/badge/Acessar-Front--end-0077B5?style=for-the-badge&logo=github&logoColor=white)](https://github.com/projetos-BD-fatec/API-3-Semestre-frontend) [![Repositório Back-end](https://img.shields.io/badge/Acessar-Back--end-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/projetos-BD-fatec/API-3-Semestre-backend)

| [Desafio](#desafio) | [Solução](#solução) | [Backlog](#backlog) | [Definition of Ready](#definition-of-ready-dor) | [Definition of Done](#definition-of-done-dod) | [Estrutura](#estrutura) | [Vídeos](#vídeos) | [Equipe](#equipe) | [Padrão de Commits](#padrão-de-commits-e-integração-jira) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |

# Desafio

O desafio consiste em criar um sistema para organizar, padronizar e acompanhar todo o percurso das guias de exames do **FUSex (Fluxo Único de Saúde e Exames)**, da solicitação médica até a liquidação final.

| 🧩 Etapas espalhadas | 💰 Conferência de valores | 🔎 Acompanhamento |
| :--- | :--- | :--- |
| O processo passa por várias etapas (solicitação, emissão da guia, realização do exame, recebimento de faturas, Lisura e liquidação), cada uma com seus próprios documentos e sistemas. | Os valores apresentados pelas clínicas precisam ser comparados com os valores do contrato, e essa conferência depende de planilhas e de análise manual. | Sem um fluxo único, é difícil saber em que etapa cada guia está e garantir que todas as etapas foram registradas e conferidas. |

# Solução

Centralizar todo o fluxo em um único sistema padronizado, que acompanha a guia da solicitação até a liquidação, com regras claras e etapas definidas:

**Solicitação → Emissão de Guia → Realização → Recebimento de Faturas → Lisura → Liquidação**

Com isso, o sistema busca garantir:

- ✅ **Segurança:** cada etapa é registrada e conferida.
- ✅ **Transparência:** valores e prazos ficam visíveis.
- ✅ **Agilidade:** sem burocracia repetida.
- ✅ **Economia:** valores revisados e conferidos com base no contrato.

# Manual de Instalação e Execução

Siga as instruções abaixo para clonar, configurar e executar a aplicação em seu ambiente local.

### 🛠️ Pré-requisitos
Certifique-se de ter instalado em sua máquina:
- **Git** (versão 2.x ou superior)
- **Java OpenJDK 25**
- **Node.js** (versão 18.x ou superior) e **npm**
- **Docker Desktop** (com Docker Compose ativo)
- **IDE/Editor:** IntelliJ IDEA ou VS Code

### 1. Clonando o Repositório Principal e Submódulos
Como o projeto utiliza submódulos do Git para versionar o Front-end e Back-end, execute o comando com a flag `--recursive`:

```bash
git clone --recursive [https://github.com/projetos-BD-fatec/API-3-Semestre-main.git](https://github.com/projetos-BD-fatec/API-3-Semestre-main.git)
cd API-3-Semestre-main
````
# Backlog

**Features**

| Requisito | Assunto | User Story | Prioridade | Sprint | Estimativa (P/M/G) | Status |
| --- | --- | --- | --- | :---: | :---: | :---: |
| [US01](docs/User_Stories/US01.md) | Registro do encaminhamento médico | Como responsável pelo FUSex, quero registrar o encaminhamento médico e os exames solicitados para iniciar o processo de atendimento. | Alta | 1 | M | ✅ |
| [US02](docs/User_Stories/US02.md) | Análise do encaminhamento | Como responsável pelo FUSex, quero analisar o encaminhamento médico para identificar os exames e procedimentos necessários. | Alta | 1 | P | ✅ |
| [US03](docs/User_Stories/US03.md) | Consulta à Planilha de Parâmetros | Como responsável pelo FUSex, quero consultar a Planilha de Parâmetros para obter os dados necessários para o encaminhamento. | Alta | 1 | P | ✅ |
| [US04](docs/User_Stories/US04.md) | Busca de clínicas e procedimentos | Como responsável pelo FUSex, quero consultar clínicas e procedimentos disponíveis para identificar o prestador adequado ao atendimento. | Alta | 1 | P | ✅ |
| [US05](docs/User_Stories/US05.md) | Preparação da Pré-Guia | Como responsável pelo FUSex, quero gerar a Pré-Guia com as informações da solicitação para deixá-la pronta para emissão. | Alta | 1 | M | ✅ |
| [US06](docs/User_Stories/US06.md) | Emissão da Guia FUSex | Como responsável pelo FUSex, quero emitir a Guia de Encaminhamento com os dados da solicitação, clínica, procedimentos e valores. | Alta | 2 | M | ✅ |
| [US07](docs/User_Stories/US07.md) | Registro da utilização da Guia | Como OCS/prestador, quero informar se a Guia foi utilizada ou não para registrar a situação da Guia no sistema. | Alta | 2 | M | ✅ |
| [US08](docs/User_Stories/US08.md) | Assinatura da Guia | Como responsável pelo FUSex, quero registrar as assinaturas necessárias na documentação para validar o encaminhamento. | Alta | 2 | M | ✅ |
| [US09](docs/User_Stories/US09.md) | Consulta da Guia pelo prestador | Como clínica/prestador, quero consultar os dados da Guia para realizar o atendimento do beneficiário. | Alta | 2 | P | ✅ |
| [US10](docs/User_Stories/US10.md) | Registro da realização | Como clínica/prestador, quero registrar a realização dos exames para que o atendimento fique registrado no sistema. | Alta | 2 | M | ✅ |
| [US11](docs/User_Stories/US11.md) | Envio das guias e documentos | Como clínica/prestador, quero encaminhar digitalmente as guias e os documentos da realização para iniciar o processo de faturamento. | Alta | 2 | G | 🔄 |
| [US12](docs/User_Stories/US12.md) | Recebimento das faturas | Como responsável pelo FUSex, quero receber digitalmente as faturas enviadas pelas clínicas para dar continuidade ao processo. | Média | 2 | P | 🔄 |
| [US13](docs/User_Stories/US13.md) | Conferência dos valores | Como responsável pela Lisura, quero comparar os valores apresentados com os valores previstos em contrato para identificar divergências. | Média | 2 | G | 🔄 |
| [US14](docs/User_Stories/US14.md) | Aprovação do pagamento | Como responsável pela Lisura, quero aprovar a solicitação após a conferência dos valores para autorizar o pagamento. | Média | 2 | P | 🔄 |
| US15 | Geração do MAPA | Como responsável pelo processo, quero gerar o MAPA com as informações necessárias para dar continuidade à liquidação. | Média | 3 |  | ⬜ |
| US16 | Liquidação | Como responsável pelo processo, quero processar os valores aprovados para concluir a liquidação do atendimento. | Média | 3 |  | ⬜ |
| US17 | Acompanhamento do fluxo | Como responsável pelo FUSex, quero acompanhar o status de cada etapa para ter visibilidade do processo desde a solicitação até a liquidação. | Média | 3 |  | ⬜ |

**Status:** ⬜ não iniciada · 🔄 em andamento · ✅ concluída 

**Legenda das estimativas**

| Tamanho | Story Points | Significado |
| :---: | :---: | --- |
| **P** | **1 ou 2** | Tela simples ou consulta em tabelas que já existem, sem nada novo para a equipe. |
| **M** | **3 ou 5** | Cadastro completo (tela, gravação no banco e validação) ou regra de negócio simples envolvendo 2 ou 3 tabelas. |
| **G** | **8** | Depende de algo externo (outro sistema, arquivo, biblioteca nova) ou tem muitas regras. Se não couber em uma sprint, deve ser dividida em duas US. |
| **GG** | **13** | Tarefa de altíssima complexidade e incerteza. Deve obrigatoriamente ser dividida em tarefas menores antes de entrar na Sprint. |

# Definition of Ready (DoR)

Critérios que uma User Story deve atender para ser considerada pronta para entrar em uma Sprint:

- [ ] A User Story está claramente descrita.
- [ ] O objetivo da funcionalidade está compreendido pela equipe.
- [ ] Os critérios de aceitação estão bem definidos.
- [ ] As informações necessárias para o desenvolvimento estão disponíveis.
- [ ] As dependências da história estão identificadas.
- [ ] A equipe esclareceu possíveis dúvidas sobre a história.
- [ ] As User Stories foram priorizadas.
- [ ] A equipe consegue estimar o esforço necessário para desenvolvê-la.

> O detalhamento deste DoR para cada User Story está no arquivo dela, em `docs/User_Stories`.

# Definition of Done (DoD)

Critérios que uma User Story deve atender para ser considerada concluída, independentemente da sprint:

- [ ] A funcionalidade está desenvolvida e integrada ao sistema.
- [ ] Todos os critérios de aceitação foram atendidos.
- [ ] A funcionalidade foi testada.
- [ ] Os testes não apresentam erros críticos.
- [ ] A funcionalidade está funcionando conforme o fluxo definido.
- [ ] O código está versionado no repositório do projeto.
- [ ] A equipe revisou e validou a entrega.
- [ ] A funcionalidade está pronta para ser apresentada/demonstrada.

# Estrutura

**Estrutura**

```
├── .github/
│   └── pull_request_template.md
├── backend/      (submódulo: API-3-Semestre-backend)
├── docker/
├── docs/
│   ├── User_Stories/
│   │   ├── US01.md
│   │   ├── US02.md
│   │   ├── US03.md
│   │   ├── US04.md
│   │   ├── US05.md
│   │   ├── US06.md
│   │   ├── US07.md
│   │   ├── US08.md
│   │   ├── US09.md
│   │   ├── US10.md
│   │   ├── US11.md
│   │   ├── US12.md
│   │   ├── US13.md
│   │   └── US14.md
│   ├── processos/
│   │   ├── definition-of-ready.md
│   │   └── definition-of-done.md
│   ├── sprints/
│   │   └── sprint-01/
│   │       └── README.md
│   └── videos/
│       ├── README.md
│       └── demonstracao-sprint1.mp4
├── frontend/     (submódulo: API-3-Semestre-frontend)
├── .gitignore
├── .gitmodules
└── README.md
```

# Vídeos

| Sprint | Vídeo |
| :---: | --- |
| Sprint 1 | [Demonstração de uso do sistema](docs/videos/demonstracao-sprint1.mp4) |

# Gestão do Projeto & Alocação de Tarefas

Para garantir total transparência no desenvolvimento e acompanhamento das atividades da equipe, todas as demandas (User Stories, Tasks e Bugs) são geridas ativamente no quadro Jira da equipe.

### Distribuição de Responsabilidades da Sprint Atual

| Membro | Função | Tarefas / US Atribuídas | Status |
| --- | --- | --- | :---: |
| Ramon Nascimento | Product Owner | Validação de DoR/DoD e refinamento do Backlog | 🔄 |
| Luis Gustavo Graciano | Scrum Master | Gestão do Kanban, Facilitação e arquitetura | 🔄 |
| Lucas Monteiro | Desenvolvedor | [US06] Emissão da Guia / [SCRUM-22] Backend | 🔄 |
| Melina Ito | Desenvolvedor | [US07] Tela e integração de utilização da Guia | 🔄 |
| Abraão Prado | Desenvolvedor | [US10] Registro de realização no Frontend | ⬜ |
| André Junqueira | Desenvolvedor | [US13] Regras de conferência de valores no Backend | ⬜ |
| João Victor | Desenvolvedor | [US11] Componente de upload de documentos | ⬜ |

# Estratégia de Branching

Para garantir a qualidade do código, a rastreabilidade das entregas e a integridade da aplicação, a equipe BugHunters adota um modelo baseado no Git Flow. 

⚠️ **Regra de Ouro: Commits diretos na branch `main` são estritamente proibidos.**

### 🌳 Organização das Branches
- **`main`:** Branch principal e ambiente de produção. Contém apenas código estável, revisado e validado.
- **`develop`:** Branch de integração contínua. Centraliza as entregas da Sprint em andamento antes de serem promovidas para a `main`.
- **`feature/SCRUM-XX-nome-da-tarefa`:** Branches criadas a partir da `develop` para o desenvolvimento de novas funcionalidades (User Stories ou Tasks).
- **`bugfix/SCRUM-XX-descricao-do-erro`:** Branches criadas para correção de bugs ou falhas identificadas.

### 🔄 Política de Integração (Pull Requests)
Todo código desenvolvido nas branches de `feature` ou `bugfix` deve ser integrado à `develop` (e posteriormente à `main`) exclusivamente através de **Pull Requests (PRs)**. 

Para que um PR seja aceito (Merge), ele deve:
1. Passar na revisão de código de pelo menos 1 outro membro da equipe.
2. Não conter conflitos com a branch de destino.
3. Ter todos os commits seguindo o padrão de nomenclatura estabelecido.

🔗 **[Acessar o Template Padrão de Pull Request do Projeto](.github/pull_request_template.md)**

# Padrão de Commits e Rastreabilidade

Para garantir o acompanhamento adequado do trabalho e a rastreabilidade (tracking) do projeto, todo código enviado ao repositório deve estar obrigatoriamente vinculado a um card ativo no Jira (User Story, Task ou Bug).

⚠️ **Nenhum commit deve ser realizado sem um card correspondente.** Caso surja uma nova demanda, melhoria ou correção de bug durante a Sprint, um novo card deve ser criado no Jira, com seu devido esforço estimado, para só então o commit ser realizado.

### 📝 Formato Obrigatório da Mensagem
As mensagens de commit devem seguir estritamente o padrão estruturado abaixo:

`[CHAVE-JIRA] tipo: descrição breve da alteração`

**Tipos permitidos:**
- `feat`: Desenvolvimento de uma nova funcionalidade (ex: criação de tela, novo endpoint).
- `fix`: Correção de um bug ou erro no sistema.
- `chore`: Configurações, manutenção de ferramentas ou atualização de dependências (ex: setup de Docker, ajustes no `package.json` ou `pom.xml`).
- `docs`: Atualizações na documentação do projeto (ex: arquivos Markdown, manuais).
- `refactor`: Reestruturação de código que não altera seu comportamento externo (ex: padronização de variáveis para inglês, mudança de injeção de dependência).

**Exemplos Práticos:**
> `[SCRUM-12] feat: cria componente de upload de documentos da fatura`
> `[SCRUM-15] fix: resolve loop infinito na validação da pré-guia`
> `[SCRUM-18] refactor: substitui @Autowired por injeção via construtor no service`
> `[SCRUM-20] docs: atualiza estratégia de branching no README`

# Equipe

| Membro | Função | Github | Linkedin |
| --- | --- | --- | --- |
| Ramon Nascimento | Product Owner | [![](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Ramon-1221) | [![](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/ramon-nascimento-3bbb68249/) |
| Luis Gustavo Graciano | Scrum Master | [![](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/gracianoluis) | [![](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/luisgustavograciano/) |
| Lucas Monteiro | Desenvolvedor | [![](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/lhmontech) | [![](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/lucas-henrique-monteiro-55101a365) |
| Melina Ito | Desenvolvedor | [![](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/melinaito1) | [![](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/melinaito/) |
| Abraão Prado | Desenvolvedor | [![](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/abraaops25) | [![](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://br.linkedin.com/in/abra%C3%A3o-prado-santana-830a06123) |
| André Junqueira | Desenvolvedor | [![](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/andre-sjunqueira) | [![](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://br.linkedin.com/in/andr%C3%A9-soares-junqueira-54668a26b) |
| João Victor | Desenvolvedor | [![](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/blom28) | — |

# Regras de Permanência da Equipe

Para assegurar o engajamento, alinhamento com os prazos acadêmicos e o cumprimento dos entregáveis com qualidade, todos os integrantes da equipe **BugHunters** declaram ciência e acordo com os seguintes compromissos:

1. **Pontualidade e Frequência:** Comparecimento obrigatório às reuniões de Daily, Demos e reuniões de planejamento do projeto. Ausências devem ser justificadas previamente ao Scrum Master ou PO.
2. **Rastreabilidade no Jira e Git:** Atualizar o status dos cards no Jira e realizar commits conforme o padrão estipulado.
3. **Respeito aos Prazos da Sprint:** Entregar os itens comprometidos na Planning dentro da Sprint correspondente. Atrasos não justificáveis serão objeto de alinhamento interno.
4. **Critério PACER (Avaliação 360°):**
   * O método PACER é utilizado para avaliar a contribuição individual em relação a Proatividade, Autonomia, Colaboração, Entrega e Resultados.
   * **Membros que obtiverem nota média inferior a 1,5 (um ponto e meio) na avaliação do PACER em uma Sprint serão formalmente convidados a se desligar do grupo BugHunters.**
