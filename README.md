# Task List

## Introduction

A task list app using Rails and GraphQL for the back-end and React (Vite) for the front-end and PostgreSQL for the database.

<p align="center">
  <a href="https://www.ruby-lang.org/">
    <img src="https://img.shields.io/badge/ruby-3.4.5-%23CC0000.svg?style=for-the-badge&logo=ruby&logoColor=white"/>
  </a>
  <a href="https://reactjs.org">
    <img src="https://img.shields.io/badge/React-19.2.1-61DAFB?style=for-the-badge&logo=react&logoColor=white"/>
  </a>
  <a href="https://vitejs.dev/">
    <img src="https://img.shields.io/badge/Vite-7.3.1-646CFF?style=for-the-badge&logo=Vite&logoColor=white"/>
  </a>
</p>

## About the project
This project was developed using the following tools:
- Backend:
- - Ruby on Rails
- - PostgreSQL
- - GraphQL
- - Docker
- - RSpec

- Frontend:
- - React with Vite
- - Apollo Client
- - Cypress
- - DnD Kit for drag and drop functionality

## Requirements

You can run this project using either **[Docker](https://github.com/zutin/task-list/README.md#installation-docker)** or **[Local Setup](https://github.com/zutin/task-list/README.md#installation-local-setup)**.

## Installation (Docker)

1. Clone this repository to your local machine:

```bash
git clone git@github.com:zutin/task-list.git
```

2. Navigate to the project directory:

```bash
cd task-list
```

3. Create a `.env` file in the root of the frontend project, you can use the example file provided:

```bash
cp task-list-front/.env.example task-list-front/.env
```

4. Start the project's Docker containers:

```bash
docker compose up
```

5. Access the application at:

```bash
http://localhost:5173
```

## Installation (Local Setup)

1. Clone this repository to your local machine:

```bash
git clone git@github.com:zutin/task-list.git
```

2. Navigate to the project directory:

```bash
cd task-list
```

3. Create a `.env` file in the root of the frontend project, you can use the example file provided:

```bash
cp task-list-front/.env.example task-list-front/.env
```

4. Install both projects dependencies:

```bash
cd task-list-back
bin/setup --skip-server

cd task-list-front
npm install
```

5. Run both projects:

```bash
cd task-list-back
bundle exec rails server -b 0.0.0.0 -p 3000

cd task-list-front
npm run dev
```

6. Access the application at:

```bash
http://localhost:5173
```

## How to run tests/specs

You can run tests by navigating to the frontend or backend project folder:

You can run *RSpec tests* using the following command:
```bash
cd task-list-back
bundle exec rspec
```

You can run *Cypress tests* using the following command:
```bash
cd task-list-front
npx cypress run
```

## API Docs
#### GraphQL API
For documentation about the GraphQL queries, mutations, and types, access [GraphQL API Documentation](https://github.com/zutin/task-list/blob/main/task-list-back/docs/graphql.md).
