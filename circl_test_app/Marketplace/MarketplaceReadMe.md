# Marketplace Module - PageSkillSellingMatching

## Overview
The Marketplace module provides a comprehensive two-sided marketplace for the Circl app, enabling users to discover projects, offer services, and find job opportunities within the student and professional community.

## Main Components

### 📱 PageSkillSellingMatching.swift
The core marketplace interface featuring a dual-tab system for Projects and Job Board functionality.

## Features

### 🎯 Two-Sided Marketplace
- **Projects Tab**: Freelance work, collaborations, co-founder searches
- **Job Board Tab**: Traditional employment opportunities

### 🔍 Smart Filtering System
**Projects Filters (Academic/Professional Fields):**
- Computer Science
- Finance
- Marketing
- Engineering
- Design
- Sales
- Accounting
- Legal
- Human Resources
- Sciences

**Job Board Filters (Employment Types):**
- Remote
- Equity
- Full-Time
- Startup

### 📊 Project Categories
- **Service Offerings**: Users providing services
- **Service Requests**: Users seeking services
- **Co-Founder Searches**: Equity-based partnerships
- **Contract Work**: Paid project collaborations

## User Interface

### 🎨 Design System
- **Primary Color**: `#004aad` (Circl Blue)
- **Accent Color**: Green for create actions
- **Typography**: System font with semantic sizing
- **Layout**: Card-based design with clear visual hierarchy

### 📋 Project Cards
Each project displays:
- **Header**: Title, Company, Industry badge
- **Top-Right**: REQUESTING/OFFERING badge + timestamp
- **Description**: Project details (3-line limit)
- **Tags**: All metadata in one scrollable row
  - Project type, compensation, remote status, company type
  - Required skills as blue-themed tags
- **Actions**: Context-aware buttons (Hire/Request Work) + bookmark

### 🛠️ Create Listing System

#### Banner Experience
- **First Time**: Promotional banner with create button
- **Dismissible**: X button in top-right corner
- **Persistent**: Green "+ Create" button appears in header after dismissal

#### Create Project Sheet
- **Type Selection**: Offering vs Requesting toggle
- **Basic Info**: Title, company, industry
- **Project Details**: Type, compensation, company type dropdowns
- **Configuration**: Remote work toggle
- **Content**: Rich description editor
- **Skills**: Dynamic tag management system
- **Validation**: Form completion requirements

#### Create Job Sheet
- **Job Details**: Title, company, location, salary
- **Configuration**: Job type and experience level
- **Position Type**: Remote work toggle
- **Content**: Comprehensive job description
- **Requirements**: Skills management
- **Benefits**: Perks and benefits system
- **Validation**: Complete form validation

## Data Structure

### ProjectListing Model
```swift
struct ProjectListing {
    let id: String
    let title: String
    let company: String
    let industry: String
    let type: String
    let description: String
    let skills: [String]
    let compensationType: String
    let isRemote: Bool
    let companyType: String
    let timePosted: String
    let isOffering: Bool
}
```

### JobListing Model
```swift
struct JobListing {
    let id: String
    let title: String
    let company: String
    let location: String
    let type: String
    let description: String
    let salaryRange: String
    let skills: [String]
    let experienceLevel: String
    let isRemote: Bool
    let benefits: [String]
    let timePosted: String
}
```

## Navigation & Integration

### 🔗 App Integration
- **Bottom Navigation**: Marketplace tab with dollar sign icon
- **Header Tabs**: Projects and Job Board switching
- **Navigation Links**: Connected to main app flow

### 📱 State Management
- **Tab Selection**: `selectedTab` for Projects/Job Board
- **Filtering**: `selectedFilter` for category filtering
- **Sheets**: `showCreateProjectSheet`, `showCreateJobSheet`
- **Persistence**: `@AppStorage` for banner dismissal state

## Mock Data

### Sample Industries
- HealthTech, FinTech, SaaS, E-commerce
- AI/Tech, Marketing, Legal Services
- BioTech, Hardware, EdTech

### Sample Projects
- Co-founder searches with equity positions
- Contract development work
- Design and consulting services
- Technical collaborations

## User Experience Flow

###### 🔄 Complete Project Workflow

#### Discovery & Initial Contact
1. **Discovery**: Browse projects/jobs with filtering
2. **Engagement**: View detailed project cards
3. **Initial Action**: Click "Request Work" or "Hire" button
4. **Direct Message**: Automated DM sent to PageMessages for discussion

#### Project Agreement Process
5. **Negotiation**: Parties communicate via PageMessages
6. **Decision**: Project owner can Accept or Deny the collaboration
7. **Project Creation**: 
   - **If Accepted**: Project gets automatically listed in "Projects" tab within the user's Circl
   - **Auto-Creation**: If user doesn't have a business Circl, one is automatically created
8. **Contract Setup**: Project terms and scope finalized in the Projects tab

#### Payment & Escrow System
9. **Payment Processing**: 
   - **If charging**: Stripe collects payment from project owner
   - **Escrow**: Funds held securely until project completion
   - **Free Projects**: Skip to project tracking phase

#### Project Execution
10. **Work Phase**: Contractor executes project deliverables
11. **Progress Tracking**: Both parties can monitor progress in Projects tab
12. **Communication**: Ongoing updates and feedback through Circl Projects

#### Completion & Payment Release
13. **Project Submission**: Contractor submits completed work
14. **Mutual Agreement**: Both parties must agree on completion in Projects tab
15. **Fund Release**: Once both parties confirm satisfaction, escrowed funds are released
16. **Payment Distribution**: Stripe processes payment to contractor's account
17. **Project Archive**: Completed project moves to completed status

### 📱 Traditional User Actions
1. **Browse**: Use filter chips to find relevant opportunities
2. **Create**: Tap "+ Create" or use the banner to post listings
3. **Engage**: Apply to projects or hire talent directly
4. **Manage**: Track applications and posted listings

## Technical Implementation

### 🏗️ Architecture
- **SwiftUI**: Modern declarative UI framework
- **MVVM Pattern**: Clean separation of concerns
- **State-driven**: Reactive UI updates
- **Modular Design**: Reusable components

### 🔧 Key Components
- **FilterButton**: Reusable filter chips
- **ProjectCard**: Rich project display cards
- **JobCard**: Job posting display cards
- **CreateProjectSheet**: Project creation form
- **CreateJobSheet**: Job creation form
- **FormField**: Reusable form input component

### 📊 Data Flow
1. **Mock Data**: Comprehensive sample content
2. **Filtering Logic**: Smart skill-based filtering
3. **Form Validation**: Complete form validation
4. **State Updates**: Reactive UI changes

---

# 🔧 Backend Development Implementation Guide

*Complete instructions for backend developers to implement the Marketplace functionality*

## 🛠️ Database Schema Requirements

#### Projects Table
```sql
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    company VARCHAR(255) NOT NULL,
    industry VARCHAR(100) NOT NULL,
    type VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    skills JSONB NOT NULL, -- Array of skill strings
    compensation_type VARCHAR(100) NOT NULL,
    is_remote BOOLEAN DEFAULT false,
    company_type VARCHAR(100) NOT NULL,
    is_offering BOOLEAN NOT NULL, -- true for offering, false for requesting
    status VARCHAR(50) DEFAULT 'active', -- active, completed, cancelled
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Add indexes for performance
    INDEX idx_projects_industry (industry),
    INDEX idx_projects_type (type),
    INDEX idx_projects_skills USING GIN (skills),
    INDEX idx_projects_offering (is_offering),
    INDEX idx_projects_status (status),
    INDEX idx_projects_created (created_at)
);
```

#### Jobs Table *(Note: Missing compensationType field from frontend)*
```sql
CREATE TABLE jobs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    company VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    type VARCHAR(100) NOT NULL, -- Full-Time, Part-Time, etc.
    description TEXT NOT NULL,
    salary_range VARCHAR(100),
    compensation_type VARCHAR(100), -- MISSING from original schema!
    skills JSONB NOT NULL,
    experience_level VARCHAR(100) NOT NULL,
    benefits JSONB, -- Array of benefit strings
    is_remote BOOLEAN DEFAULT false,
    company_type VARCHAR(100), -- MISSING from original schema!
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Add indexes for performance
    INDEX idx_jobs_type (type),
    INDEX idx_jobs_location (location),
    INDEX idx_jobs_remote (is_remote),
    INDEX idx_jobs_skills USING GIN (skills)
);
```

#### Banner Dismissal Tracking *(Missing from original)*
```sql
CREATE TABLE user_marketplace_settings (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) UNIQUE,
    banner_dismissed BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

#### Skills & Industries Tables *(For dropdown consistency)*
```sql
CREATE TABLE marketplace_skills (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50), -- cs, finance, marketing, etc.
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE marketplace_industries (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Seed data for industries
INSERT INTO marketplace_industries (name) VALUES 
('HealthTech'), ('FinTech'), ('SaaS'), ('E-commerce'), ('AI/Tech'), 
('Marketing'), ('Legal Services'), ('BioTech'), ('Hardware'), ('EdTech');
```

#### Project Applications Table
```sql
CREATE TABLE project_applications (
    id SERIAL PRIMARY KEY,
    project_id INTEGER REFERENCES projects(id),
    applicant_id INTEGER REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'pending', -- pending, accepted, denied
    message TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

#### Project Collaborations Table
```sql
CREATE TABLE project_collaborations (
    id SERIAL PRIMARY KEY,
    project_id INTEGER REFERENCES projects(id),
    client_id INTEGER REFERENCES users(id), -- Project owner
    contractor_id INTEGER REFERENCES users(id), -- Service provider
    circl_id INTEGER REFERENCES circls(id), -- Associated business circl
    stripe_payment_intent_id VARCHAR(255), -- For paid projects
    amount_cents INTEGER, -- Payment amount in cents
    status VARCHAR(50) DEFAULT 'active', -- active, completed, cancelled
    client_approved BOOLEAN DEFAULT false,
    contractor_approved BOOLEAN DEFAULT false,
    payment_released BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);
```

### 🔗 API Endpoints

#### Projects Management
```
GET /api/marketplace/projects
- Query params: 
  * filter: 'all'|'offering'|'requesting'|'cs'|'finance'|'marketing'|'engineering'|'design'|'sales'|'accounting'|'legal'|'hr'|'sciences'
  * page: number (default: 1)
  * limit: number (default: 20)
- Returns: Paginated list of projects with filtering

POST /api/marketplace/projects
- Body: {
    title: string,
    company: string, 
    industry: string,
    type: string,
    description: string,
    skills: string[],
    compensationType: string,
    isRemote: boolean,
    companyType: string,
    isOffering: boolean
  }
- Returns: Created project

PUT /api/marketplace/projects/:id
- Body: Same as POST (partial updates allowed)
- Authorization: Only project owner
- Returns: Updated project

DELETE /api/marketplace/projects/:id
- Authorization: Only project owner
- Returns: Success confirmation

GET /api/marketplace/projects/:id
- Returns: Single project with detailed info
```

#### Jobs Management
```
GET /api/marketplace/jobs
- Query params:
  * filter: 'all'|'remote'|'equity'|'fulltime'|'startup'
  * page: number (default: 1) 
  * limit: number (default: 20)
- Returns: Paginated list of jobs

POST /api/marketplace/jobs
- Body: {
    title: string,
    company: string,
    location: string,
    type: string,
    description: string,
    salaryRange: string,
    compensationType: string,
    skills: string[],
    experienceLevel: string,
    benefits: string[],
    isRemote: boolean,
    companyType: string
  }
- Returns: Created job

PUT /api/marketplace/jobs/:id
- Body: Same as POST (partial updates allowed)
- Authorization: Only job owner
- Returns: Updated job

DELETE /api/marketplace/jobs/:id
- Authorization: Only job owner
- Returns: Success confirmation
```

#### User Settings *(New requirement)*
```
GET /api/marketplace/settings
- Returns: { bannerDismissed: boolean }

PUT /api/marketplace/settings
- Body: { bannerDismissed: boolean }
- Returns: Updated settings
```

#### Filter Data *(For dropdown consistency)*
```
GET /api/marketplace/industries
- Returns: Array of available industries

GET /api/marketplace/skills
- Query params: category (optional)
- Returns: Array of skills, optionally filtered by category

GET /api/marketplace/filters/project-types
- Returns: ["Project Collaboration", "Service Offering", "Co-Founder Search", "Contract", "Internship"]

GET /api/marketplace/filters/compensation-types  
- Returns: ["Paid Contract", "Equity Position", "Hourly Rate", "Equity + Salary", "Collaboration", "Project-based"]

GET /api/marketplace/filters/company-types
- Returns: ["Startup", "Small Business", "Enterprise", "Freelance", "Non-Profit"]
```

#### Applications & Messaging
```
POST /api/marketplace/projects/:id/apply
- Body: { message: string }
- Actions: Creates application, sends DM to PageMessages
- Returns: Application confirmation

PUT /api/marketplace/applications/:id/respond
- Body: { status: 'accepted' | 'denied' }
- Actions: Updates application, creates collaboration if accepted
- Returns: Updated application status

GET /api/marketplace/applications/user/:userId
- Returns: User's sent and received applications
```

#### Collaboration Management
```
GET /api/marketplace/collaborations/user/:userId
- Returns: User's active collaborations

PUT /api/marketplace/collaborations/:id/approve
- Body: { approved_by: 'client' | 'contractor' }
- Actions: Updates approval status, releases payment if both approve
- Returns: Updated collaboration

POST /api/marketplace/collaborations/:id/payment
- Body: Stripe payment details
- Actions: Creates escrow payment via Stripe
- Returns: Payment confirmation
```

### 💳 Stripe Integration Requirements

#### Payment Flow Implementation
```javascript
// 1. Create Payment Intent (when collaboration starts)
const paymentIntent = await stripe.paymentIntents.create({
    amount: amountInCents,
    currency: 'usd',
    payment_method: paymentMethodId,
    confirmation_method: 'manual',
    confirm: true,
    capture_method: 'manual', // Hold funds in escrow
    metadata: {
        collaboration_id: collaborationId,
        project_id: projectId,
        client_id: clientId,
        contractor_id: contractorId
    }
});

// 2. Capture Payment (when both parties approve completion)
const captured = await stripe.paymentIntents.capture(paymentIntentId, {
    amount_to_capture: amountInCents
});
```

#### Webhooks Required
```javascript
// Handle Stripe webhooks for payment status updates
app.post('/api/webhooks/stripe', (req, res) => {
    const event = req.body;
    
    switch (event.type) {
        case 'payment_intent.succeeded':
            // Update collaboration payment status
            break;
        case 'payment_intent.payment_failed':
            // Handle payment failure
            break;
    }
});
```

### 🔄 Frontend Integration Points

#### API Service Layer *(Matches actual SwiftUI implementation)*
```swift
class MarketplaceService: ObservableObject {
    private let baseURL = "https://api.circl.app"
    
    // Projects
    func fetchProjects(filter: String, page: Int = 1) async throws -> [ProjectListing] {
        let url = "\(baseURL)/api/marketplace/projects?filter=\(filter)&page=\(page)"
        // Implementation with URLSession
    }
    
    func createProject(_ project: CreateProjectRequest) async throws -> ProjectListing {
        let url = "\(baseURL)/api/marketplace/projects"
        // POST implementation
    }
    
    func applyToProject(_ projectId: String, message: String) async throws -> Bool {
        let url = "\(baseURL)/api/marketplace/projects/\(projectId)/apply"
        // Implementation that triggers DM creation
    }
    
    // Jobs
    func fetchJobs(filter: String, page: Int = 1) async throws -> [JobListing] {
        let url = "\(baseURL)/api/marketplace/jobs?filter=\(filter)&page=\(page)"
        // Implementation with URLSession
    }
    
    func createJob(_ job: CreateJobRequest) async throws -> JobListing {
        let url = "\(baseURL)/api/marketplace/jobs"
        // POST implementation
    }
    
    // User Settings
    func getUserSettings() async throws -> MarketplaceSettings {
        let url = "\(baseURL)/api/marketplace/settings"
        // GET implementation
    }
    
    func updateBannerDismissed(_ dismissed: Bool) async throws -> Bool {
        let url = "\(baseURL)/api/marketplace/settings"
        // PUT implementation
    }
    
    // Filter Data
    func getIndustries() async throws -> [String] {
        let url = "\(baseURL)/api/marketplace/industries"
        // GET implementation
    }
}

// Request/Response Models
struct CreateProjectRequest: Codable {
    let title: String
    let company: String
    let industry: String
    let type: String
    let description: String
    let skills: [String]
    let compensationType: String
    let isRemote: Bool
    let companyType: String
    let isOffering: Bool
}

struct CreateJobRequest: Codable {
    let title: String
    let company: String
    let location: String
    let type: String
    let description: String
    let salaryRange: String
    let compensationType: String
    let skills: [String]
    let experienceLevel: String
    let benefits: [String]
    let isRemote: Bool
    let companyType: String
}

struct MarketplaceSettings: Codable {
    let bannerDismissed: Bool
}
```

#### State Management Updates *(Replace MockData.swift)*
```swift
struct PageSkillSellingMatching: View {
    @StateObject private var marketplaceService = MarketplaceService()
    @State private var projects: [ProjectListing] = []
    @State private var jobs: [JobListing] = []
    @State private var isLoading = false
    @State private var error: Error?
    
    // Replace MockData calls with API calls
    private func loadMarketplaceData() {
        Task {
            isLoading = true
            do {
                if selectedTab == "projects" {
                    projects = try await marketplaceService.fetchProjects(
                        filter: selectedFilter
                    )
                } else {
                    jobs = try await marketplaceService.fetchJobs(
                        filter: selectedFilter
                    )
                }
                
                // Load user settings for banner state
                let settings = try await marketplaceService.getUserSettings()
                bannerDismissed = settings.bannerDismissed
                
            } catch {
                self.error = error
                print("Error loading marketplace data: \(error)")
            }
            isLoading = false
        }
    }
    
    // Update create functions to use API
    private func createProject() {
        Task {
            do {
                let request = CreateProjectRequest(
                    title: title,
                    company: company,
                    industry: industry,
                    type: selectedType,
                    description: description,
                    skills: skills,
                    compensationType: selectedCompensation,
                    isRemote: isRemote,
                    companyType: selectedCompanyType,
                    isOffering: isOffering
                )
                
                let newProject = try await marketplaceService.createProject(request)
                projects.append(newProject)
                showCreateProjectSheet = false
                
            } catch {
                self.error = error
            }
        }
    }
}
```

#### Filter Implementation *(Matches actual filtering logic)*
```swift
// Backend should implement the same filter categories as frontend
let filterMapping = [
    "cs": ["SwiftUI", "iOS", "React", "Python", "JavaScript", "Programming", "Development"],
    "finance": ["Finance", "FinTech", "Investment", "Banking", "Financial Analysis"],
    "marketing": ["Marketing", "Growth", "Content Creation", "Social Media", "SEO"],
    "engineering": ["Engineering", "Mechanical", "Electrical", "Civil", "CAD"],
    "design": ["Design", "UI/UX", "Figma", "Graphic Design", "Web Design"],
    "sales": ["Sales", "Business Development", "Lead Generation", "CRM"],
    "accounting": ["Accounting", "Bookkeeping", "Tax", "Financial Reporting"],
    "legal": ["Legal", "Law", "Contract", "Compliance", "IP"],
    "hr": ["Human Resources", "Recruitment", "HRIS", "Performance Management"],
    "sciences": ["Biology", "Chemistry", "Research", "Laboratory", "Scientific Writing"]
]
```

### 🔐 Authentication & Authorization

#### Required Permissions
```sql
-- Project permissions
INSERT INTO permissions (name, description) VALUES 
('marketplace.projects.create', 'Create marketplace projects'),
('marketplace.projects.edit', 'Edit own projects'),
('marketplace.projects.apply', 'Apply to projects'),
('marketplace.projects.manage', 'Manage project applications');

-- Collaboration permissions  
INSERT INTO permissions (name, description) VALUES
('marketplace.collaborate', 'Participate in project collaborations'),
('marketplace.payments.manage', 'Manage escrow payments');
```

### 📧 Notification System Integration

#### Required Notifications
```javascript
// Send notifications for key events
const notificationEvents = {
    'project.application.received': 'New application for your project',
    'project.application.accepted': 'Your application was accepted',
    'project.application.denied': 'Your application was denied', 
    'collaboration.created': 'New collaboration started',
    'collaboration.completed': 'Project marked as complete',
    'payment.escrowed': 'Payment held in escrow',
    'payment.released': 'Payment has been released'
};
```

### 🔍 Search & Filtering Backend

#### Elasticsearch/Search Implementation
```javascript
// Advanced search with filters
const searchProjects = async (query, filters) => {
    return await elasticsearch.search({
        index: 'projects',
        body: {
            query: {
                bool: {
                    must: [
                        { match: { description: query } },
                        { terms: { skills: filters.skills } },
                        { term: { is_offering: filters.isOffering } }
                    ],
                    filter: [
                        { term: { status: 'active' } }
                    ]
                }
            }
        }
    });
};
```

### 📊 Analytics & Metrics

#### Key Metrics to Track
```sql
-- Marketplace analytics tables
CREATE TABLE marketplace_metrics (
    id SERIAL PRIMARY KEY,
    metric_name VARCHAR(100) NOT NULL,
    metric_value INTEGER NOT NULL,
    date DATE NOT NULL,
    metadata JSONB
);

-- Track: project views, applications, success rate, etc.
```

## Future Enhancements

### 🚀 Potential Features
- **Backend Integration**: Real data persistence
- **User Profiles**: Enhanced user information
- **Messaging System**: Direct communication
- **Application Tracking**: Status management
- **Advanced Search**: Full-text search capabilities
- **Push Notifications**: New opportunity alerts
- **Analytics**: User engagement metrics

### 🔄 Improvements
- **Performance**: Lazy loading for large datasets
- **Accessibility**: VoiceOver and accessibility features
- **Internationalization**: Multi-language support
- **Offline Support**: Cached content availability

---

## Quick Start Guide

1. **Browse**: Use filter chips to find relevant opportunities
2. **Create**: Tap "+ Create" or use the banner to post listings
3. **Engage**: Apply to projects or hire talent directly
4. **Manage**: Track applications and posted listings

The Marketplace module provides a complete platform for connecting talent with opportunities in the Circl ecosystem, designed for seamless user experience and professional networking.