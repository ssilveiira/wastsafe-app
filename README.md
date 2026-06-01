<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white"/>
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white"/>
</p>

<h1 align="center">♻️ WastSafe</h1>
<p align="center">
  <strong>Plataforma digital para reuso e logística reversa de componentes eletrônicos</strong><br/>
  Conectando geradores de resíduos e recicladores com base nos princípios da Economia Circular.
</p>

---

## 📋 Sobre o Projeto

O **WastSafe** é um e-commerce sustentável desenvolvido como projeto acadêmico no curso de **Tecnologia em Análise e Desenvolvimento de Sistemas** da **Fatec Itapetininga**, na disciplina de Laboratório de Engenharia de Software (1º Semestre / 2026).

O Brasil é o 5º país que mais gera lixo eletrônico no mundo, mas apenas 3% é descartado corretamente. O WastSafe surge como resposta a esse problema, criando um ecossistema digital que transforma resíduos eletrônicos em recursos valiosos — conectando quem tem equipamentos sem uso a quem pode reutilizá-los.

---

## ✨ Funcionalidades

| ID | Funcionalidade | Descrição |
|----|---------------|-----------|
| RF-01 | 👤 Cadastro de Usuários | Cadastro de pessoas físicas e jurídicas pela interface mobile |
| RF-02 | 🔐 Autenticação | Login via e-mail e senha |
| RF-03 | 📦 Anunciar Material | Publicação de componentes eletrônicos com foto, categoria e descrição |
| RF-04 | 🔍 Marketplace | Catálogo com busca e filtragem por categoria ou condição |
| RF-05 | 🚚 Rastreamento de Pedido | Acompanhamento do status da logística reversa |
| RF-06 | ℹ️ Telas Informativas | Conteúdo educativo sobre economia circular e uso da plataforma |

---

## ⚙️ Requisitos Não Funcionais

- **Usabilidade:** Interface responsiva com Widgets Flutter para diversos tamanhos de tela
- **Segurança:** Criptografia AES-256 para dados pessoais e financeiros
- **Eficiência:** Tempo de resposta máximo de 5 segundos nas operações principais
- **Portabilidade:** Compatível com Android e iOS com consistência visual
- **Escalabilidade:** Suporte a até 500 acessos simultâneos, expansível para 1.000
- **Disponibilidade:** 99,9% de uptime (máx. 4h de interrupção/mês)

---

## 🏗️ Arquitetura

O projeto adota a arquitetura **Cliente-Servidor** com organização em **Camadas**:

```
┌─────────────────────────────┐
│        Interface (UI)        │  ← Widgets Flutter
├─────────────────────────────┤
│      Lógica de Negócio       │  ← Regras e validações
├─────────────────────────────┤
│       Acesso a Dados         │  ← Comunicação com servidor
└─────────────────────────────┘
```

---

## 🛠️ Tecnologias

- [Flutter](https://flutter.dev/) — Framework mobile/web
- [Dart](https://dart.dev/) — Linguagem de programação

---

## 🚀 Como Executar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado
- Android Studio ou VS Code com extensão Flutter
- Emulador Android/iOS ou dispositivo físico

### Instalação

```bash
# Clone o repositório
git clone https://github.com/ssilveiira/wastsafe-app.git

# Acesse a pasta do projeto
cd wastsafe-app

# Instale as dependências
flutter pub get

# Execute o projeto
flutter run
```

---

## 👩‍💻 Autores

| [<img src="https://github.com/ssilveiira.png" width="80px"/><br/><sub>Ana Clara Silveira</sub>](https://github.com/ssilveiira) | Otávio Machado de Oliveira |
|:---:|:---:|

---

## 🎓 Informações Acadêmicas

> **Instituição:** Fatec Itapetininga — Centro Paula Souza  
> **Curso:** Tecnologia em Análise e Desenvolvimento de Sistemas  
> **Disciplina:** Laboratório de Engenharia de Software  
> **Orientador:** Prof. Danilo Ruy Gomes  
> **Semestre:** 1º Semestre / 2026  

---

## 📄 Licença

Este projeto foi desenvolvido para fins acadêmicos.

---

<p align="center">Feito com 💚 para um futuro mais sustentável</p>
