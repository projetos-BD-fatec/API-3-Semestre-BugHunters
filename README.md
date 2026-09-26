# 📌 DataMed - Sua saúde, sem complicação.

Este é o **repositório principal e centralizador** do projeto (Equipe BugHunters). Ele é dedicado à documentação oficial, regras de negócio, acompanhamento das Sprints (Scrum) e gestão da arquitetura baseada em submódulos.

Para visualizar o código-fonte da aplicação, acesse os repositórios específicos abaixo:

<div align="center">
  <a href="https://github.com/projetos-BD-fatec/API-3-Semestre-frontend/tree/4882d27095454ebbfac9ddcaf633afac71b02307">
    <img src="https://img.shields.io/badge/Acessar-Front--end-0077B5?style=for-the-badge&logo=github&logoColor=white" alt="Repositório Front-end">
  </a>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <a href="https://github.com/projetos-BD-fatec/API-3-Semestre-backend/tree/dd5c06d9c1970521aa3d2fbcd89f57b6da1b9ab5">
    <img src="https://img.shields.io/badge/Acessar-Back--end-100000?style=for-the-badge&logo=github&logoColor=white" alt="Repositório Back-end">
  </a>
</div>
<br>

<div align="center">


</div>
<div align="center">

| [Desafio](#desafio) | [Solução](#solução) | [Backlog](#backlog) | [Definition of Ready](#definition-of-ready-dor) | [Definition of Done](#definition-of-done-dod) | [Estrutura](#estrutura) | [Equipe](#equipe) | [Padrão de Commits](#padrão-de-commits-e-integração-jira) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |


</div>

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

**Status:** ⬜ não iniciada · 🔄 em andamento · ✅ concluída

**Legenda das estimativas**

| Tamanho | Story Points | Significado |
| :---: | :---: | :--- |
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

# Padrão de Commits e Integração Jira

Este projeto utiliza **Smart Commits** para rastrear e movimentar os cards automaticamente no Jira. 

Todo commit deve obrigatoriamente iniciar com a chave da tarefa e seguir o formato:
`[CHAVE-DO-JIRA] tipo: descrição breve #comando`

**Tipos permitidos:**
- `feat`: Nova funcionalidade.
- `fix`: Correção de bug.
- `chore`: Manutenção, dependências ou setup.
- `docs`: Atualização de documentação.
- `refactor`: Melhoria de código sem alterar funcionalidade.

**Comandos de Automação (Status do Jira):**
Adicione as hashtags no final da mensagem do commit para mover o card no board:
- `#in-progress`: Move a tarefa para a coluna **Em Andamento**.
- `#done`: Move a tarefa para **Concluído**.

**Exemplos práticos de commits:**
> `[SCRUM-12] feat: cria a tela de login do sistema #in-progress`
> `[SCRUM-15] fix: resolve erro de cálculo na planilha de conferência #done`
> `[SCRUM-17] docs: atualiza alinhamento da tabela de equipe no README #done`

# Equipe

<div align="center">
  <table>
    <tr>
      <th>Membro</th>
      <th>Função</th>
      <th>Github</th>
      <th>Linkedin</th>
    </tr>
    <tr>
      <td align="center">Ramon Nascimento</td>
      <td align="center">Product Owner</td>
      <td align="center"><a href="https://github.com/Ramon-1221"><img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white"></a></td>
      <td align="center"><a href="https://www.linkedin.com/in/ramon-nascimento-3bbb68249/"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"></a></td>
    </tr>
    <tr>
      <td align="center">Luis Gustavo Graciano</td>
      <td align="center">Scrum Master</td>
      <td align="center"><a href="https://github.com/gracianoluis"><img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white"></a></td>
      <td align="center"><a href="https://www.linkedin.com/in/luisgustavograciano/"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"></a></td>
    </tr>
    <tr>
      <td align="center">Lucas Monteiro</td>
      <td align="center">Desenvolvedor</td>
      <td align="center"><a href="https://github.com/lhmontech"><img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white"></a></td>
      <td align="center"><a href="https://www.linkedin.com/in/lucas-henrique-monteiro-55101a365"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"></a></td>
    </tr>
    <tr>
      <td align="center">Melina Ito</td>
      <td align="center">Desenvolvedor</td>
      <td align="center"><a href="https://github.com/melinaito1"><img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white"></a></td>
      <td align="center"><a href="https://www.linkedin.com/in/melinaito/"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"></a></td>
    </tr>
    <tr>
      <td align="center">Abraão Prado</td>
      <td align="center">Desenvolvedor</td>
      <td align="center"><a href="https://github.com/abraaops25"><img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white"></a></td>
      <td align="center"><a href="https://br.linkedin.com/in/abra%C3%A3o-prado-santana-830a06123"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"></a></td>
    </tr>
    <tr>
      <td align="center">André Junqueira</td>
      <td align="center">Desenvolvedor</td>
      <td align="center"><a href="https://github.com/andre-sjunqueira"><img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white"></a></td>
      <td align="center"><a href="https://br.linkedin.com/in/andr%C3%A9-soares-junqueira-54668a26b"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"></a></td>
    </tr>
    <tr>
      <td align="center">João Victor</td>
      <td align="center">Desenvolvedor</td>
      <td align="center"><a href="https://github.com/blom28"><img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white"></a></td>
      <td align="center"><a href="LINK_DO_JOAO_AQUI"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"></a></td>
    </tr>
  </table>
</div>
