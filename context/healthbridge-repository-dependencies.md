# HealthBridge - Repository Dependency Map

> **Last updated:** 2026-02-27
> **Purpose:** Cross-repository dependency analysis for all HealthBridge application/service repositories (excludes test automation repos)
> **Usage:** Reference document for QA agents, developers, and architects to understand inter-service dependencies

---

## Table of Contents

1. [Repository Overview](#1-repository-overview)
2. [Consumer / Provider: HTTP API Dependencies](#2-consumer--provider-http-api-dependencies)
3. [Consumer / Provider: Shared Database Dependencies](#3-consumer--provider-shared-database-dependencies)
4. [Consumer / Provider: Shared NuGet Package Dependencies](#4-consumer--provider-shared-nuget-package-dependencies)
5. [Architecture Diagram](#5-architecture-diagram)
6. [Key Findings](#6-key-findings)
7. [Team Ownership](#7-team-ownership)

---

## 1. Repository Overview

| # | Repository | Tech Stack | Purpose | Status |
|---|-----------|------------|---------|--------|
| 1 | **HealthBridge-Web** | C# / ASP.NET Core 8.0 | Core web application - all clinical and administrative modules | Production |
| 2 | **HealthBridge-Portal** | C# / .NET Core + React/TS | Patient self-service portal (appointments, records, messaging) | Production |
| 3 | **HealthBridge-Api** | C# / .NET Core | Public API gateway for third-party integrations | Production |
| 4 | **HealthBridge-Mobile** | Flutter / Dart | Mobile app for clinicians and patients (iOS/Android) | Production |
| 5 | **HealthBridge-Claims-Processing** | C# / .NET 8, RabbitMQ, PostgreSQL | Insurance claim submission and adjudication gateway | Production |
| 6 | **HealthBridge-Prescriptions-Api** | C# / .NET 8 + GraphQL (HotChocolate) | Medication orders, e-prescribing, refill management | Production |

---

## 2. Consumer / Provider: HTTP API Dependencies

These are runtime dependencies where one service calls another via HTTP/REST/GraphQL APIs.

| # | Consumer | Provider | Protocol | What is Consumed | Integration Details |
|---|----------|----------|----------|-----------------|---------------------|
| 1 | **HealthBridge-Portal** | **Prescriptions-Api** | REST | Active medications, refill requests | `/internal/api/prescriptions/v1/*` |
| 2 | **HealthBridge-Api** | **Prescriptions-Api** | REST | Prescription data for pharmacy integrations | `PrescriptionsApiHost` config |
| 3 | **HealthBridge-Api** | **HealthBridge-Web** (Gateway) | REST | Clinical summaries, provider lists, facility KPIs | `HealthBridgeGatewayApiHost` config |
| 4 | **HealthBridge-Mobile** | **API Gateway** (external) | REST | All mobile data: appointments, prescriptions, lab results, messaging | OAuth + API Key; routes to HealthBridge-Web backend |
| 5 | **HealthBridge-Web** | **Drug Interaction API** (external) | REST | Real-time drug interaction checking | API key authentication |
| 6 | **HealthBridge-Web** | **OCR/Document Scanner** (external) | REST | Medical document digitization (OCR) | Basic auth |
| 7 | **Claims-Processing** | **External Clearinghouse** (external) | REST | Claim submission, remittance processing | Basic auth, async polling pattern |

### Provider Popularity (Most Consumed Services)

| Provider | # of Consumers | Consumers |
|----------|---------------|-----------|
| **Prescriptions-Api** | 2 | Portal, Api |
| **HealthBridge-Web** | 2 | Api, Mobile (via Gateway) |

---

## 3. Consumer / Provider: Shared Database Dependencies

HealthBridge uses multi-tenant database isolation with a shared reference database pattern.

| # | Consumer | Database(s) | Access Type | What is Read/Written |
|---|----------|------------|------------|---------------------|
| 1 | **HealthBridge-Web** | `healthbridge_ref` + facility DBs | Read/Write | Core clinical data (all modules) |
| 2 | **HealthBridge-Portal** | PostgreSQL (own DB) | Read/Write | Patient preferences, messaging, session data |
| 3 | **HealthBridge-Api** | PostgreSQL (API keys) + SQL Server (`healthbridge_ref`) | Read/Write | API consumer management, rate limiting |
| 4 | **Prescriptions-Api** | `healthbridge_ref` + facility DBs | Read/Write | Medication orders, prescriptions, refills |
| 5 | **Claims-Processing** | PostgreSQL (5 separate DBs per service) | Read/Write | Claims data, payment tracking, validation results |

### Key Database Note

> **`healthbridge_ref`** is the central reference database shared by multiple services. Changes to its schema impact HealthBridge-Web, Prescriptions-Api, and HealthBridge-Api. The facility databases follow a multi-tenant pattern where each healthcare facility has its own isolated database.

---

## 4. Consumer / Provider: Shared NuGet Package Dependencies

All .NET microservices depend on shared internal NuGet packages distributed via GitHub Packages (`https://nuget.pkg.github.com/HealthBridge-Platform/`).

| Package Family | Version | Consumer Repositories |
|---------------|---------|----------------------|
| `HealthBridge.Shared.Presentation.Api` | **8.0.5** | Prescriptions-Api |
| `HealthBridge.Shared.ApplicationServices` | **8.0.5** | Prescriptions-Api |
| `HealthBridge.Shared.Infrastructure.EntityFramework` | **8.0.5** | Prescriptions-Api |
| `HealthBridge.Shared.DomainModels` | **8.0.5** | Prescriptions-Api |
| `HealthBridge.Shared.Presentation.Api.Serilog` | **8.0.5** | Prescriptions-Api |
| `HealthBridge.Platform.Extensions` | **6.0.0** | Claims-Processing (RabbitMQ, PostgreSQL, S3, Auth helpers) |

### What the Shared Packages Provide

| Package | Key Functionality |
|---------|------------------|
| `Shared.Presentation.Api` | RSA JWT auth, API middleware, error handling, Swagger |
| `Shared.ApplicationServices` | CQRS command/query handler framework, service registration |
| `Shared.Infrastructure.EntityFramework` | Multi-tenant DbContext, SQL Server connection management |
| `Shared.DomainModels` | Entity base classes, value objects, Result pattern |
| `Platform.Extensions` | RabbitMQ producer/consumer, PostgreSQL, S3, Serilog config |

---

## 5. Architecture Diagram

```
+---------------------------------------------------------------------------+
|                        EXTERNAL SERVICES                                   |
|  Drug Interaction API <-- HealthBridge-Web                                 |
|  OCR/Document Scanner <-- HealthBridge-Web                                 |
|  External Clearinghouse <-- Claims-Processing                              |
|  API Gateway <-- HealthBridge-Mobile                                       |
+---------------------------------------------------------------------------+
                                    |
    ================================================================
                     API CONSUMERS (UI / ORCHESTRATORS)
    ================================================================
                                    |
    +------------------+  +-----------------------+
    | HealthBridge-Web |  |   HealthBridge-Api    |
    | (Core App)       |  |   (Public Gateway)    |
    | C#/ASP.NET Core  |  |   C#/.NET Core        |
    |                  |  |                       |
    | Consumes:        |  | Consumes:             |
    | - Drug Interact. |  | - HB-Web Gateway      |
    | - OCR Service    |  | - Prescriptions-Api   |
    |                  |  |                       |
    | Provides:        |  |                       |
    | - Gateway API    |  |                       |
    | - Clinical REST  |  |                       |
    +--------+---------+  +-----------------------+
             |
    +--------+---------+  +----------------------+
    | HealthBridge-    |  | HealthBridge-Mobile  |
    | Portal           |  | (Flutter/Dart)       |
    | (Patient Self-   |  |                      |
    |  Service)        |  | Consumes:            |
    | C#/.NET + React  |  | - API Gateway        |
    |                  |  |   -> HB-Web backend  |
    | Consumes:        |  |                      |
    | - Prescriptions  |  |                      |
    +------------------+  +----------------------+

    ================================================================
                     DOMAIN MICROSERVICES (PROVIDERS)
    ================================================================

    +--------------------+  +--------------------+
    | Prescriptions-Api  |  | Claims-Processing  |
    | REST + GraphQL     |  | REST + RabbitMQ    |
    | .NET 8             |  | .NET 8             |
    |                    |  | PostgreSQL x5      |
    | Medications,       |  |                    |
    | E-prescribing,     |  | 6 microservices:   |
    | Refills, Drug Intx |  | Gateway, Validator,|
    |                    |  | Submitter, Tracker |
    | Consumers: 2       |  |                    |
    +--------------------+  +--------------------+

    ================================================================
                        SHARED INFRASTRUCTURE
    ================================================================

    +---------------------------------------------------------+
    |  SQL Server: healthbridge_ref (reference) + facility DBs|
    |  PostgreSQL: Portal, Claims, Api                        |
    |  Redis: GraphQL schema federation + distributed cache   |
    |  RabbitMQ: Claims-Processing inter-service messaging    |
    |  AWS: ECR, S3, SQS, Secrets Manager                    |
    |  NuGet: HealthBridge.Shared.* packages (v8.0.5)         |
    |  Auth: RSA-signed JWT Bearer tokens (shared keys)       |
    |  CI/CD: GitHub Actions -> AWS ECR -> Kubernetes         |
    +---------------------------------------------------------+
```

---

## 6. Key Findings

### 6.1 HealthBridge-Web is the Gravitational Center

Almost all services read from and write to HealthBridge-Web's SQL Server databases (`healthbridge_ref` + facility databases). It serves as both the **biggest data provider** (shared database) and a **consumer** of external services (Drug Interaction, OCR). The Gateway API it exposes is consumed by HealthBridge-Api for clinical data summaries.

### 6.2 Prescriptions-Api is a Clinical Safety Hotspot

The Prescriptions-Api serves medication data to both Portal and Api. Failures in this service could result in missed drug interaction warnings or stale medication data -- a patient safety concern.

### 6.3 Claims-Processing is Architecturally Isolated

Claims-Processing uses a completely different tech stack: **.NET 8, PostgreSQL (5 databases), RabbitMQ** for inter-service messaging, and **S3** for document storage. It has zero direct dependencies on other HealthBridge repos and communicates only with the external Insurance Clearinghouse.

### 6.4 All Microservices Share Authentication Pattern

All .NET microservices use **RSA-signed JWT Bearer tokens** with a common public key stored in AWS Secrets Manager. This enables zero-trust service-to-service communication with facility-scoped authorization.

### 6.5 Multi-Database Architecture

The ecosystem uses two database technologies:
- **SQL Server** -- HealthBridge-Web legacy databases (shared by multiple services)
- **PostgreSQL** -- Modern services (Portal, Claims-Processing, Api)

---

## 7. Team Ownership

| Repository | Owner Team | Slack Channel |
|-----------|-----------|---------------|
| HealthBridge-Web | Multiple teams | Various |
| HealthBridge-Portal | Portal team | #hb-portal |
| HealthBridge-Api | Platform team | #hb-platform |
| HealthBridge-Mobile | Mobile team | #hb-mobile |
| Claims-Processing | Revenue Cycle | #hb-revenue-cycle |
| Prescriptions-Api | Pharmacy team | #hb-pharmacy |

---

## QA Impact: Why This Map Matters

When reviewing code changes (HM-*, HBP-*, HMM-* branches), QA agents should consider:

1. **Changes to `healthbridge_ref` database schema** affect multiple services
2. **Changes to HealthBridge.Shared.* packages** affect Prescriptions-Api
3. **Prescriptions-Api changes** are patient-safety-critical -- must validate drug interaction checking and medication data still works across Portal and Api consumers
4. **Claims-Processing is isolated** -- changes there do not affect other HealthBridge services
5. **HealthBridge-Web changes** have the highest blast radius due to shared databases and Gateway API consumption
