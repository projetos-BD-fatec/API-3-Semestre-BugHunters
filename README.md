| [Desafio](#desafio) | [Solução](#solução) | [Backlog](#backlog) | [Definition of Ready](#definition-of-ready-dor) | [Definition of Done](#definition-of-done-dod) | [Instalação](#instalação) | [Estrutura](#estrutura) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |

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

# Backlog

**Features**

| Requisito | Assunto | User Story | Prioridade | Sprint | Estimativa (P/M/G) | Status |
| --- | --- | --- | --- | :---: | :---: | :---: |
| [US01](docs/User_Stories/US01.md) | Registro do encaminhamento médico | Como responsável pelo FUSex, quero registrar o encaminhamento médico e os exames solicitados para iniciar o processo de atendimento. | Alta | 1 | M | ⬜ |
| [US02](docs/User_Stories/US02.md) | Análise do encaminhamento | Como responsável pelo FUSex, quero analisar o encaminhamento médico para identificar os exames e procedimentos necessários. | Alta | 1 | P | ⬜ |
| [US03](docs/User_Stories/US03.md) | Consulta à Planilha de Parâmetros | Como responsável pelo FUSex, quero consultar a Planilha de Parâmetros para obter os dados necessários para o encaminhamento. | Alta | 1 | P | ⬜ |
| [US04](docs/User_Stories/US04.md) | Busca de clínicas e procedimentos | Como responsável pelo FUSex, quero consultar clínicas e procedimentos disponíveis para identificar o prestador adequado ao atendimento. | Alta | 1 | P | ⬜ |
| [US05](docs/User_Stories/US05.md) | Preparação da Pré-Guia | Como responsável pelo FUSex, quero gerar a Pré-Guia com as informações da solicitação para deixá-la pronta para emissão. | Alta | 1 | M | ⬜ |
| [US06](docs/User_Stories/US06.md) | Emissão da Guia FUSex | Como responsável pelo FUSex, quero emitir a Guia de Encaminhamento com os dados da solicitação, clínica, procedimentos e valores. | Alta | 1 | M | ⬜ |
| [US07](docs/User_Stories/US07.md) | Registro da utilização da Guia | Como OCS/prestador, quero informar se a Guia foi utilizada ou não para registrar a situação da Guia no sistema. | Alta | 1 | P | ⬜ |
| [US08](docs/User_Stories/US08.md) | Assinatura da Guia | Como responsável pelo FUSex, quero registrar as assinaturas necessárias na documentação para validar o encaminhamento. | Alta | 1 | M | ⬜ |
| [US09](docs/User_Stories/US09.md) | Consulta da Guia pelo prestador | Como clínica/prestador, quero consultar os dados da Guia para realizar o atendimento do beneficiário. | Alta | 1 | P | ⬜ |
| [US10](docs/User_Stories/US10.md) | Registro da realização | Como clínica/prestador, quero registrar a realização dos exames para que o atendimento fique registrado no sistema. | Alta | 1 | M | ⬜ |
| US11 | Envio das guias e documentos | Como clínica/prestador, quero encaminhar digitalmente as guias e os documentos da realização para iniciar o processo de faturamento. | Alta | 2 | M | ⬜ |
| US12 | Recebimento das faturas | Como responsável pelo FUSex, quero receber digitalmente as faturas enviadas pelas clínicas para dar continuidade ao processo. | Média | 2 | P | ⬜ |
| US13 | Integração com SisFat | Como responsável pelo FUSex, quero integrar o recebimento das faturas ao SisFat para organizar o processo de faturamento. | Média | 2 | G | ⬜ |
| US14 | Conferência dos valores | Como responsável pela Lisura, quero comparar os valores apresentados com os valores previstos em contrato para identificar divergências. | Média | 2 | G | ⬜ |
| US15 | Planilha de Conferência | Como responsável pela Lisura, quero gerar e utilizar uma planilha de conferência para registrar os valores analisados. | Média | 2 | M | ⬜ |
| US16 | Revisão da Lisura | Como responsável pela Lisura, quero revisar os valores apresentados e conferidos para determinar o valor devido. | Média | 2 | P | ⬜ |
| US17 | Aprovação do pagamento | Como responsável pela Lisura, quero aprovar a solicitação após a conferência dos valores para autorizar o pagamento. | Média | 2 | M | ⬜ |
| US18 | Auditoria | Como responsável pelo processo, quero encaminhar os dados para auditoria para garantir que as informações estejam corretas antes da liquidação. | Média | 2 | M | ⬜ |
| US19 | Geração do MAPA | Como responsável pelo processo, quero gerar o MAPA com as informações necessárias para dar continuidade à liquidação. | Média | 3 | M | ⬜ |
| US20 | Liquidação | Como responsável pelo processo, quero processar os valores aprovados para concluir a liquidação do atendimento. | Média | 3 | G | ⬜ |
| US21 | Acompanhamento do fluxo | Como responsável pelo FUSex, quero acompanhar o status de cada etapa para ter visibilidade do processo desde a solicitação até a liquidação. | Média | 3 | P | ⬜ |

**Legenda das estimativas**

| Tamanho | Significado |
| :---: | --- |
| **P** | Tela simples ou consulta em tabelas que já existem, sem nada novo para a equipe. |
| **M** | Cadastro completo (tela, gravação no banco e validação) ou regra de negócio simples envolvendo 2 ou 3 tabelas. |
| **G** | Depende de algo externo (outro sistema, arquivo, biblioteca nova) ou tem muitas regras. Se não couber em uma sprint, deve ser dividida em duas US. |

**Status:** ⬜ não iniciada · 🔄 em andamento · ✅ concluída

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


# Instalação

**Manual de instalação**

Este guia fornece as instruções necessárias para configurar e executar o projeto localmente, para desenvolvimento ou avaliação.

Antes de começar, certifique-se de ter os seguintes pré-requisitos instalados:

```
→ Java JDK 17 ou superior.
→ Maven 3.8+ para gestão de dependências.
→ Git (utilize o Git Bash para execução de comandos).
→ IDE recomendada: IntelliJ IDEA.
```

> **Nota:** caso prefira não utilizar o terminal, você também pode baixar o projeto diretamente pelo GitHub: clique no botão `< > Code` e selecione `Download ZIP`.

1. Abra o Git Bash e execute:

```
git clone https://github.com/<organização>/<repositório>.git
```

2. Abra a IDE:

```
Abra o IntelliJ IDEA, selecione a pasta onde o repositório foi clonado e abra a pasta projeto.
```

3. Para que a aplicação se conecte ao banco de dados externo (Supabase), navegue até a pasta `src/main/resources/`, crie um arquivo de texto chamado `db.properties` e cole a linha abaixo, substituindo os valores pelas credenciais fornecidas pela equipe:

```
db.url=jdbc:postgresql://<host>:<porta>/<banco>?user=<usuario>&password=<senha>&sslmode=require&prepareThreshold=0
```

> **Importante:** o arquivo `db.properties` contém credenciais e não é versionado (está listado no `.gitignore`).

4. Execute o aplicativo, dentro da pasta `projeto`:

```
mvn clean javafx:run
```

> **Nota:** caso prefira não utilizar o terminal, você também pode executar o projeto pelo IntelliJ, abrindo a classe principal (`App`) e clicando no botão `Run`.

# Estrutura

**Estrutura**

```
├── README.md
├── .github/
│   └── pull_request_template.md
├── projeto/
│   ├── src/
│   │   └── main/
│   │       ├── java/
│   │       └── resources/
│   ├── .gitignore
│   └── pom.xml
└── docs/
    ├── User_Stories/
    │   ├── US01.md
    │   ├── US02.md
    │   ├── US03.md
    │   ├── US04.md
    │   ├── US05.md
    │   ├── US06.md
    │   ├── US07.md
    │   ├── US08.md
    │   ├── US09.md
    │   └── US10.md
    ├── imagens/
    ├── processos/
    │   ├── definition-of-ready.md
    │   └── definition-of-done.md
    ├── sprints/
    │   └── sprint-01/
    │       └── README.md
    └── videos/
```
