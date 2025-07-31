# ♻️ SecureExchange

**SecureExchange** é um aplicativo mobile desenvolvido em Flutter que facilita a troca de objetos entre usuários, promovendo o **comércio circular**, a **redução de desperdícios** e o **consumo consciente**. Usuários podem cadastrar itens que desejam trocar, visualizar objetos de outras pessoas e propor trocas diretamente pelo app.

---

## 🎨 Design no Figma

Você pode visualizar o protótipo no [Figma aqui](https://www.figma.com/design/8CUkYBKPw2dD1hvCma2ymP/Secure-Exchange?node-id=0-1&t=GsTfExtzZXmAgMd1-1).

---

## 🧩 Funcionalidades

- 📦 Cadastro de objetos com foto, título e descrição 
- 🔍 Filtro por título e navegação fácil
- 🔄 Proposta de troca entre usuários
- 💬 Comunicação entre os envolvidos
- 👤 Cadastro e autenticação de usuários
- 📱 Interface simples, rápida e responsiva

---

## 🛠️ Tecnologias Utilizadas

- **Flutter** (SDK multiplataforma)
- **Firebase Storage / Imgur** (armazenamento de imagens)
- **Parse Server SDK Flutter** (para autenticação e persistência)

---

## 📦 Instalação

1. **Clone o repositório**  
```bash
git clone https://github.com/LRz00/secure_exchange.git
cd secure_exchange
```

2. **Instale as dependências**

```bash
flutter pub get
```

3. **Configure o Parse Server**
Adicione as chaves do Back4App ao seu .env

```env
PARSE_APPLICATION_ID=APPLICATION ID DISPONIVEL NO DASHBOARD DO BACK4APP
PARSE_CLIENT_KEY=SUA CHAVE
PARSE_SERVER_URL=https://parseapi.back4app.com
```

4. **Rode o App**
```bash
flutter run
```
