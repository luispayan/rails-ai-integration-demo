# Rails AI Integration DEMO

This application is a demo platform featuring AI-powered product search, chat, and dynamic reporting capabilities. It leverages vector embeddings, semantic search, and real-time communication to enhance user experience.

## Features

- **Semantic Product Search**
  - Products page with semantic search using vector embeddings.
  - Embedding generator for product models.
  - Search capabilities based on vector distances.

- **AI Chat Integration**
  - AI chat available on the product page.
  - Real-time communication via Action Cable and product channels.
  - Streaming responses from the AI service.

- **Embeddings Management**
  - Ability to generate embeddings for multiple models.
  - `VectorService` for vector normalization.
  - `Embeddable` concern to enable embeddings on any model.
  - Background jobs to generate context configs and embeddings for all relevant models.

- **Dynamic Reports**
  - Admin view to generate dynamic reports.
  - Reports generated based on the database schema.
  - CSV reports sent directly to the browser.

- **Setup**
  - Includes required database migrations and models.
  - Seed data for demo and testing purposes.


## 🛠️ Setup Instructions

### 1. Clone the repository

```bash
git clone git@github.com:luispayan/rails-ai-integration-demo.git
cd rails-ai-integration-demo
```
### 2. Install dependencies

```
bundle install
```

### 3. Database setup

```
rails db:setup
# or manually:
rails db:create
rails db:migrate
rails db:seed
```

---

## 🤖 Install Ollama (Locally)

Ollama is used for local LLM inference.

### 🔗 Instructions:  
Follow the official setup guide:  
👉 https://ollama.com/download

Once installed, you will need to pull needed models

```
ollama pull llama3
ollama pull nomic-embed-text
```

Make sure the Ollama server is running.

```
ollama serve
```
---

## 📦 Install pgvector

`pgvector` is a PostgreSQL extension for storing and querying vector embeddings.

### 🔗 Instructions:
Follow the installation guide based on your OS:  
👉 https://github.com/pgvector/pgvector#installation

### Example for macOS with Homebrew:
```
brew install pgvector
```
---

## 🚀 Running the App

### Start Rails server

```
bin/rails server
```

### Start TailwindCSS watcher

```
bin/rails tailwindcss:watch
```

Make sure both are running for development to work correctly.

---

## ✅ Additional Scripts (Optional)

You can define additional custom scripts in `bin/` or via rake tasks as needed.

---

