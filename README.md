Aqui está o README atualizado com instruções detalhadas sobre como instalar e compilar o jogo em Windows e Mac, além de como postar o jogo na plataforma Game Jolt:

```markdown
# Friday Night Funkin' - Entrega 1

## Descrição do Projeto
Este projeto envolve a criação de uma versão customizada do jogo *Friday Night Funkin'*, que inclui duas novas setas interativas:
- **Seta de Cura**: Recupera totalmente a vida do personagem ao ser acionada.
- **Seta Bomba**: Reduz a vida do personagem pela metade ao ser acionada.

## Repositório
O código do jogo está disponível no GitHub: [Friday Night Funkin - Govinda Systems DAO](https://github.com/govinda777/Friday_Night_Funkin_Govinda_Systems_DAO)

## Engine de Compilação
O jogo será compilado usando a [FNF-PsychEngine](https://github.com/govinda777/FNF-PsychEngine).

## Penalidade por Atraso
Uma multa de 5% será aplicada por cada dia de atraso na entrega do projeto.

## Instruções de Instalação e Compilação

### Windows
1. **Baixe e instale Node.js**: Baixe o instalador de Node.js do [site oficial](https://nodejs.org/) e siga as instruções de instalação.
2. **Clone o repositório**: Abra o prompt de comando e digite:
   ```
   git clone https://github.com/govinda777/Friday_Night_Funkin_Govinda_Systems_DAO.git
   cd Friday_Night_Funkin_Govinda_Systems_DAO
   ```
3. **Instale as dependências**:
   ```
   yarn install
   ```
4. **Compile o jogo**:
   ```
   yarn dev
   ```

### Mac
1. **Instale Node.js**: Use o Homebrew para instalar Node.js:
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   brew install node
   ```
2. **Clone o repositório**:
   ```
   git clone https://github.com/govinda777/Friday_Night_Funkin_Govinda_Systems_DAO.git
   cd Friday_Night_Funkin_Govinda_Systems_DAO
   ```
3. **Instale as dependências**:
   ```
   yarn install
   ```
4. **Compile o jogo**:
   ```
   yarn dev
   ```

## Postagem no Game Jolt
Para postar o jogo na Game Jolt, siga estas etapas:
1. **Crie uma conta** no Game Jolt, se ainda não tiver uma.
2. **Crie uma nova página de jogo** indo em 'Dashboard' > 'Your Games' > 'Add a Game'.
3. **Configure a página do jogo**, adicionando títulos, descrições, imagens, e tags relacionadas ao seu jogo.
4. **Carregue os arquivos do jogo** na seção de arquivos do jogo. Certifique-se de incluir um arquivo executável para Windows e Mac.
5. **Publique o jogo** ajustando as configurações de visibilidade e acessando a opção 'Publish' para tornar o jogo disponível publicamente.

## Logo e Informações da Empresa
![Logo da Govinda Systems DAO](https://www.govindasystems.com/logo.png)

Para mais informações sobre a empresa e outros projetos, visite: [Govinda Systems DAO](https://www.govindasystems.com/)

---

Este documento oferece um guia completo para o desenvolvimento, compilação e publicação do projeto, garantindo uma implementação eficaz e uma distribuição suave do jogo.
```