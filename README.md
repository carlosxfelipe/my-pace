# 🏃‍♂️ MyPace

App iOS para registro e acompanhamento de corridas, calculando automaticamente o pace (tempo por quilômetro).

## 📱 Sobre o App

MyPace é um aplicativo simples e eficiente para corredores que querem registrar suas corridas e acompanhar seu progresso. O app funciona 100% offline, mas também oferece sincronização opcional com a nuvem para backup e acesso multi-dispositivo.

### ✨ Funcionalidades

- ✅ **Registro de Corridas** - Salve distância, tempo e data de cada treino
- 📊 **Cálculo Automático de Pace** - Veja seu ritmo em min/km instantaneamente
- 📅 **Histórico Completo** - Visualize todas as suas corridas ordenadas por data
- 🗑️ **Gestão Fácil** - Delete corridas com swipe
- 🌙 **Temas** - Modo claro, escuro ou automático (segue o sistema)
- 💾 **Modo Offline** - Funciona completamente sem internet
- ☁️ **Sincronização Opcional** - Login opcional para backup na nuvem
- 🔄 **Sync Híbrido** - Dados salvos localmente + API quando logado

## 🛠️ Tecnologias

### iOS App

- **SwiftUI** - Interface moderna e declarativa
- **SwiftData** - Persistência local com SQLite
- **iOS 26.1+** - Recursos mais recentes da Apple
- **Xcode 26.1.1+** - Desenvolvimento nativo

### Backend (Opcional)

- **Django REST Framework** - API REST robusta
- **PostgreSQL** - Banco de dados via Neon DB
- **Token Authentication** - Autenticação segura
- **Render** - Hospedagem em produção

## 📦 Estrutura do Projeto

```
MyPace/
├── MyPace/                    # App principal
│   ├── MyPaceApp.swift       # Entry point
│   ├── Run.swift             # Modelo de dados
│   ├── Views/
│   │   ├── RootView.swift    # View principal com tabs
│   │   ├── ContentView.swift # Formulário de cadastro
│   │   ├── HistoryView.swift # Lista de corridas
│   │   ├── SettingsView.swift # Configurações e login
│   │   ├── LoginView.swift   # Autenticação
│   │   └── GlassBottomBar.swift # Bottom navigation
│   └── Services/
│       ├── APIService.swift  # Chamadas HTTP
│       ├── AuthManager.swift # Gerenciamento de login
│       └── SyncManager.swift # Sincronização híbrida
└── README.md                 # Este arquivo
```

## 🚀 Como Rodar o Projeto

### Pré-requisitos

- macOS com Xcode 26.1.1+
- iOS 26.1+ (simulador ou dispositivo real)
- Conta Apple Developer (para rodar em dispositivo físico)

### Instalação

1. **Clone o repositório**

   ```bash
   git clone https://github.com/carlosxfelipe/my-pace.git
   cd my-pace
   ```

2. **Abra no Xcode**

   ```bash
   open MyPace.xcodeproj
   ```

3. **Execute o app**
   - Selecione um simulador ou dispositivo
   - Pressione `Cmd + R` ou clique no botão Play

### 🔐 Configurando Signing (obrigatório)

1. Selecione o **projeto** no Xcode
2. Vá em **Targets → MyPace**
3. Abra **Signing & Capabilities**
4. Em **Team**, selecione seu Apple ID

Se não aparecer:

- `Xcode → Settings → Accounts`
- Adicione seu Apple ID

### Modo Offline (Padrão)

O app funciona 100% offline sem necessidade de configuração adicional. Todos os dados são salvos localmente no dispositivo usando SwiftData.

### Modo Online (Opcional)

Para habilitar sincronização na nuvem:

1. **Configure o backend** (Django REST Framework + PostgreSQL)
2. **Inicie o app**
3. **Vá em Configurações** → **Fazer login**
4. **Faça login ou crie uma conta**
5. **Suas corridas locais** serão automaticamente enviadas para a nuvem
6. **Dados sincronizam** automaticamente em novos cadastros e exclusões

## 🎨 Design

### Interface

- **Glass Morphism** - Bottom bar com efeito de vidro fosco
- **Layout Adaptativo** - Interface otimizada para diferentes tamanhos de tela
- **Temas** - Suporte completo para modo claro e escuro
- **Localização PT-BR** - Interface em português brasileiro

### Telas

1. **Início** - Formulário para registrar nova corrida
2. **Histórico** - Lista de todas as corridas com swipe to delete
3. **Configurações** - Temas, login/logout e sincronização manual

## 💾 Persistência de Dados

### SwiftData Local

- Banco SQLite automático
- Dados persistem entre fechamentos do app
- Funciona 100% offline
- Sem necessidade de configuração

### Sincronização com API (Opcional)

- **Login opcional** nas configurações
- **Upload automático** de corridas locais após login
- **Download automático** de corridas da nuvem
- **Sincronização bidirecional** - Create e Delete em ambos os lugares
- **Fallback local** - Se API falhar, dados ficam salvos localmente

## 🔐 Autenticação

### Modo Offline

- Sem necessidade de cadastro
- Dados locais no dispositivo
- Total privacidade

### Modo Online

- Login com email e senha
- Token authentication (Django REST)
- Token salvo localmente (UserDefaults)
- Logout limpa token mas mantém dados locais

## 🌐 Backend API

### Endpoints Principais

```
POST   /api/auth/register/  - Criar conta
POST   /api/auth/login/     - Fazer login
GET    /api/runs/           - Listar corridas
POST   /api/runs/           - Criar corrida
DELETE /api/runs/{id}/      - Deletar corrida
GET    /api/runs/stats/     - Estatísticas
```

### Hospedagem

- **Produção**: [https://mypace-backend.onrender.com](https://mypace-backend.onrender.com)
- **Docs**: [https://mypace-backend.onrender.com/api/docs/](https://mypace-backend.onrender.com/api/docs/)

## 🧪 Testes

O projeto está configurado para desenvolvimento. Para adicionar testes:

```swift
// Unit Tests
XCTestCase para modelos e lógica de negócio

// UI Tests
XCUITest para fluxos de navegação e interação
```

## 📄 Licença

Este projeto está sob a licença MIT.
