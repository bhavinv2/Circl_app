import SwiftUI
import Foundation

// MARK: - Tutorial Content Factory
extension TutorialManager {
    
    // MARK: - Entrepreneur Tutorial Flow
    func createEntrepreneurTutorial() -> TutorialFlow {
        let steps = [
            // 1. Welcome & Overview (navigate to forum for next step)
            TutorialStep(
                title: "Welcome to Circl, Entrepreneur!",
                description: "Let's show you how Circl can accelerate your entrepreneurial journey",
                targetView: "main_navigation",
                message: "As an entrepreneur, you need tools to find co-founders, investors, mentors, and grow your network. Circl is designed specifically for ambitious founders like you.",
                navigationDestination: "PageForum", // Navigate to forum for next step
                highlightRect: nil,
                tooltipAlignment: .center,
                duration: nil,
                isInteractive: false
            ),
            
            // 2. Home Feed - Bulletin Board (navigate to network for next step)
            TutorialStep(
                title: "Your Entrepreneurial Bulletin Board",
                description: "Share your updates and see what others in the community are posting",
                targetView: "home_tab",
                message: "Think of this as your community bulletin board where entrepreneurs share wins, challenges, insights, and opportunities. Post your own updates, celebrate milestones, and engage with fellow founders' content to build meaningful connections.",
                navigationDestination: "PageUnifiedNetworking", // Navigate to network for next step
                highlightRect: CGRect(x: 50, y: 100, width: 300, height: 400),
                tooltipAlignment: .bottom,
                duration: nil,
                isInteractive: false
            ),
            
            // 3. Network Tab - Co-founder & Mentor Finding (now already on PageUnifiedNetworking)
            TutorialStep(
                title: "Find Co-Founders & Mentors",
                description: "Connect with potential co-founders, experienced mentors, and strategic partners",
                targetView: "network_tab",
                message: "This is your most powerful tool as an entrepreneur. Search for co-founders with complementary skills, experienced mentors who've been where you're going, and industry experts who can provide valuable guidance for your startup journey.",
                navigationDestination: "PageCircles", // Navigate to circles for next step
                highlightRect: CGRect(x: 80, y: 150, width: 250, height: 350),
                tooltipAlignment: .top,
                duration: nil,
                isInteractive: true
            ),
            
            // 4. Business Operations Hub (now already on PageCircles)
            TutorialStep(
                title: "Run Your Business Through Circles",
                description: "Use Circles as your business management and collaboration platform",
                targetView: "circles_tab",
                message: "Create a circle to run your business operations. Manage tasks, track KPIs, centralize team communication, and coordinate with co-founders. It's your startup's command center in one organized space.",
                navigationDestination: nil, // Stay on circles for next step
                highlightRect: CGRect(x: 50, y: 100, width: 300, height: 350),
                tooltipAlignment: .bottom,
                duration: nil,
                isInteractive: false
            ),
            
            // 5. Circles - Industry Communities
            // 5. Social Features (already on PageCircles from previous step)
            TutorialStep(
                title: "Join Entrepreneurial Circles",
                description: "Connect with like-minded founders and industry-specific groups",
                targetView: "circles_tab",
                message: "Join circles based on your industry, business model, or stage of growth. Share challenges, celebrate wins, and learn from other entrepreneurs facing similar journeys.",
                navigationDestination: nil, // Stay on circles for next step
                highlightRect: CGRect(x: 160, y: 150, width: 250, height: 300),
                tooltipAlignment: .top,
                duration: nil,
                isInteractive: false
            ),
            
            // 6. Advanced Circles Usage (already on PageCircles from previous step)
            TutorialStep(
                title: "Create or Join Strategic Circles",
                description: "Build communities around your startup or join investor/advisor groups",
                targetView: "circles_tab",
                message: "Create a circle for your startup team and advisors, or join exclusive investor networks and accelerator groups. Use circles strategically to build your startup's ecosystem.",
                navigationDestination: "PageBusinessProfile", // Navigate to business profile for next step
                highlightRect: CGRect(x: 100, y: 200, width: 280, height: 250),
                tooltipAlignment: .leading,
                duration: nil,
                isInteractive: false
            ),
            
            // 7. Business Profile Creation (navigate to resources for next step)
            TutorialStep(
                title: "Showcase Your Venture",
                description: "Create a compelling business profile to attract investors and co-founders",
                targetView: "business_profile_tab",
                message: "Your business profile is crucial for attracting investors and co-founders. Share your startup's mission, traction, funding needs, and what roles you're looking to fill.",
                navigationDestination: "PageEntrepreneurResources", // Navigate to resources for next step
                highlightRect: CGRect(x: 30, y: 120, width: 340, height: 350),
                tooltipAlignment: .top,
                duration: nil,
                isInteractive: false
            ),
            
            // 8. Professional Services (navigate to messages for next step)
            TutorialStep(
                title: "Access Startup Services",
                description: "Find lawyers, accountants, and other professionals for your business",
                targetView: "professional_services",
                message: "Access pre-vetted professionals offering startup-specific services like incorporation, accounting, marketing, and legal advice. Many offer special rates for early-stage companies.",
                navigationDestination: "PageMessages", // Navigate to messages for next step
                highlightRect: CGRect(x: 50, y: 200, width: 300, height: 200),
                tooltipAlignment: .bottom,
                duration: nil,
                isInteractive: false
            ),
            
            // 9. Collaboration Hub (navigate to forum for next step)
            TutorialStep(
                title: "Conversate, Collaborate, Pass Networks, and Sell",
                description: "Use messages for deep connections and business opportunities",
                targetView: "messages_tab",
                message: "Use messages to have meaningful conversations with mentors, collaborate with co-founders and team members, pass valuable network connections to others, and engage with potential clients or customers. This is where relationships turn into business opportunities.",
                navigationDestination: "PageForum", // Navigate back to forum for final step
                highlightRect: CGRect(x: 60, y: 100, width: 280, height: 400),
                tooltipAlignment: .trailing,
                duration: nil,
                isInteractive: false
            ),
            
            // 10. Success Strategies (already on PageForum from previous step)
            TutorialStep(
                title: "Entrepreneur Success Tips",
                description: "Make the most of Circl for your startup journey",
                targetView: "success_tips",
                message: "Pro tips: Update your business profile regularly, engage authentically in circles, be specific about what you're looking for, and always follow up on connections. Consistency builds trust!",
                navigationDestination: nil,
                highlightRect: nil,
                tooltipAlignment: .center,
                duration: nil,
                isInteractive: false
            )
        ]
        
        return TutorialFlow(
            userType: .entrepreneur,
            title: "Entrepreneur's Guide to Circl",
            description: "Learn how to leverage Circl to find co-founders, investors, and grow your startup",
            steps: steps + [createTutorialAccessStep(), createFinalCommunityStep()],
            estimatedDuration: 10 * 60, // 10 minutes (8 steps + tutorial access + final step)
            isRequired: true
        )
    }
    
    // MARK: - Student Tutorial Flow
    func createStudentTutorial() -> TutorialFlow {
        let steps = [
                        // 1/9. Welcome (navigate to forum for next step)
            TutorialStep(
                title: "Welcome to Circl, Student!",
                description: "The job market has changed, getting hired and even keeping your job is harder now than ever",
                targetView: "main_navigation",
                message: "In Circl, you will build your future, from being part of a project from a business to boost your resume, opportunities to getting hired, and even choosing to help build a startup!",
                navigationDestination: "PageForum", // Navigate to forum for next step
                highlightRect: nil,
                tooltipAlignment: .center,
                duration: nil,
                isInteractive: false
            ),
            
            // 2/9. Learn the Market (navigate to network for next step)
            TutorialStep(
                title: "Learn the Market and Discuss!",
                description: "Get insights from companies and entrepreneurs",
                targetView: "home_tab",
                message: "The home feed is your research database. Read stories, learn failures and successes, and stay updated on market trends. This knowledge will be invaluable for your future ventures.",
                navigationDestination: "PageUnifiedNetworking", // Navigate to network for next step
                highlightRect: CGRect(x: 50, y: 100, width: 300, height: 400),
                tooltipAlignment: .bottom,
                duration: nil,
                isInteractive: false
            ),
            
            // 3/9. Find Mentors (navigate to forum for next step)
            TutorialStep(
                title: "Find Mentors & Learn from Experts",
                description: "Connect with industry professionals with experience and willingness to guide",
                targetView: "network_tab",
                message: "Many successful employees and entrepreneurs love mentoring students. Use the network to find mentors in your field of interest, ask for advice, and learn from their experiences. This is pure gold for your development!",
                navigationDestination: "PageForum", // Navigate to forum for collaboration step
                highlightRect: CGRect(x: 80, y: 150, width: 250, height: 350),
                tooltipAlignment: .top,
                duration: nil,
                isInteractive: true
            ),
            
            // 4/9. Collaborate and Build Projects (navigate to circles for next step)
            TutorialStep(
                title: "Collaborate, Collaborate, Collaborate, Maybe Make Money",
                description: "Building your future doesn't involve building alone, that's sad and hard",
                targetView: "forum_tab",
                message: "Circl is the first networking app where you can actually collaborate with professionals. Find projects from our project/job listing board. If you think it's necessary, don't hesitate to charge a business for your service. Build a team with your friends. Your future is yours!",
                navigationDestination: "PageCircles", // Navigate to circles for next step
                highlightRect: CGRect(x: 50, y: 100, width: 300, height: 400),
                tooltipAlignment: .bottom,
                duration: nil,
                isInteractive: false
            ),
            
            // 5/9. Join Student Organizations (navigate to profile for next step)
            TutorialStep(
                title: "Join Your Student Organization's Circl",
                description: "Supercharge your network further by being involved on campus",
                targetView: "circles_tab",
                message: "Joining organizations gives you insider access to their partner companies, their alumni network, and their professional workshops giving you better development than most students who are not in one.",
                navigationDestination: "ProfilePage", // Navigate to profile for next step
                highlightRect: CGRect(x: 160, y: 150, width: 250, height: 300),
                tooltipAlignment: .top,
                duration: nil,
                isInteractive: false
            ),
            
            // 6/9. Create Organization Circle (navigate to profile for next step)
            TutorialStep(
                title: "Create a Circle for Your Organization",
                description: "If you're a member of a student org, create a Circle for your organization",
                targetView: "circles_tab",
                message: "Centralize your messaging, have a calendar with built-in event check-in features, collect payments and dues through our built-in Stripe integration, manage your members, and much more. Transform how your organization operates and engages with its community!",
                navigationDestination: "ProfilePage", // Navigate to profile for next step
                highlightRect: CGRect(x: 160, y: 150, width: 250, height: 300),
                tooltipAlignment: .top,
                duration: nil,
                isInteractive: false
            ),
            
            // 7/9. Complete Profile (navigate to messages for next step)
            TutorialStep(
                title: "Complete Your Profile",
                description: "Help other professionals understand you more",
                targetView: "profile_tab",
                message: "Circl is built on collaboration, having an incomplete profile may cause distrust between users, besides if the community understands you better, they'll know how to work with you best!",
                navigationDestination: "PageMessages", // Navigate to messages for next step
                highlightRect: CGRect(x: 50, y: 150, width: 300, height: 300),
                tooltipAlignment: .bottom,
                duration: nil,
                isInteractive: false
            ),
            
            // 8/9. Connect and Message (navigate to forum for final step)
            TutorialStep(
                title: "Connect and Message Professionally",
                description: "Build relationships that will shape your career",
                targetView: "messages_tab",
                message: "Use messages to have deeper conversations with mentors, collaborate on projects, and build lasting professional relationships. Remember to be respectful, genuine, and always follow up on commitments.",
                navigationDestination: "PageForum", // Navigate to forum for final step
                highlightRect: CGRect(x: 60, y: 100, width: 280, height: 400),
                tooltipAlignment: .trailing,
                duration: nil,
                isInteractive: false
            ),
            
            // 8/9. Networking Strategy (navigate to forum for next step)
            TutorialStep(
                title: "Student Networking Strategy",
                description: "Learn how to network effectively as a student",
                targetView: "messages_tab",
                message: "When reaching out to professionals be genuine about being a student. Don't hesitate to provide value to them in order to get attention. Ask thoughtful questions, show you've done your research, and offer to help with small tasks. You got this!",
                navigationDestination: "PageForum", // Navigate to forum for next step
                highlightRect: CGRect(x: 60, y: 100, width: 280, height: 400),
                tooltipAlignment: .trailing,
                duration: nil,
                isInteractive: false
            ),
            
            // 9/9. Build Your Future (already on PageForum)
            TutorialStep(
                title: "Build Your Future",
                description: "Use Circl to explore different paths",
                targetView: "success_tips",
                message: "Explore industries, talk to founders and other professionals. Get projects from our project board. Try entrepreneurship, it's not as scary as you think it is. In Circl you can build a team! Dream Big!",
                navigationDestination: nil, // Already on PageForum from previous step
                highlightRect: nil,
                tooltipAlignment: .center,
                duration: nil,
                isInteractive: false
            )
        ]
        
        return TutorialFlow(
            userType: .student,
            title: "Student's Guide to Building Your Future",
            description: "Learn how to use Circl to build your career, find opportunities, and explore your potential",
            steps: steps + [createTutorialAccessStep(), createFinalCommunityStep()], // Tutorial access + final community step
            estimatedDuration: 10 * 60, // 10 minutes (9 steps + tutorial access + final community step)
            isRequired: true
        )
    }
    
    // MARK: - Student Entrepreneur Tutorial Flow
    func createStudentEntrepreneurTutorial() -> TutorialFlow {
        let steps = [
            // 1. Welcome Student Entrepreneurs (navigate to forum for next step)
            TutorialStep(
                title: "Welcome to Circl, Future Entrepreneur!",
                description: "Discover how Circl can jumpstart your entrepreneurial education",
                targetView: "main_navigation",
                message: "As a student entrepreneur, you're perfectly positioned to learn, network, and start building your entrepreneurial journey. Circl connects you with experienced founders, mentors, and peers.",
                navigationDestination: "PageForum", // Navigate to forum for next step
                highlightRect: nil,
                tooltipAlignment: .center,
                duration: nil,
                isInteractive: false
            ),
            
            // 2. Learning-Focused Home Feed (navigate to network for next step)
            TutorialStep(
                title: "Learn from Founder Stories �",
                description: "Get insights from real entrepreneurs and startup case studies",
                targetView: "home_tab",
                message: "The home feed is your entrepreneurship classroom. Read founder stories, learn from failures and successes, and stay updated on startup trends. This knowledge will be invaluable for your future ventures.",
                navigationDestination: "PageUnifiedNetworking", // Navigate to network for next step
                highlightRect: CGRect(x: 50, y: 100, width: 300, height: 400),
                tooltipAlignment: .bottom,
                duration: nil,
                isInteractive: false
            ),
            
            // 3. Mentorship Focus (navigate to circles for next step)
            TutorialStep(
                title: "Find Mentors & Learn from Experts",
                description: "Connect with experienced entrepreneurs willing to guide students",
                targetView: "network_tab",
                message: "Many successful entrepreneurs love mentoring students. Use the network to find mentors in your field of interest, ask for advice, and learn from their experiences. This is pure gold for your development!",
                navigationDestination: "PageCircles", // Navigate to circles for next step
                highlightRect: CGRect(x: 80, y: 150, width: 250, height: 350),
                tooltipAlignment: .top,
                duration: nil,
                isInteractive: true
            ),
            
            // 4. Student Communities (navigate to stay on circles for next step)
            TutorialStep(
                title: "Join Student Entrepreneur Circles",
                description: "Connect with fellow student entrepreneurs and recent graduates",
                targetView: "circles_tab",
                message: "Join circles like 'Student Entrepreneurs', 'College Startup Founders', or industry-specific groups. Share ideas, find potential co-founders, and learn from peers who are on similar journeys.",
                navigationDestination: nil, // Stay on circles for next step
                highlightRect: CGRect(x: 160, y: 150, width: 250, height: 300),
                tooltipAlignment: .top,
                duration: nil,
                isInteractive: false
            ),
            
            // 5. Run Business Through Circles (stay on circles for next step)
            TutorialStep(
                title: "Run Your Business Through Circles",
                description: "Use Circles as your business management platform",
                targetView: "circles_tab",
                message: "Create a Circle to run your business operations. Manage tasks and KPIs, centralize messaging for your employees, use the calendar feature for meetings and deadlines, and keep everything organized in one powerful platform designed for collaboration.",
                navigationDestination: nil, // Stay on circles for next step
                highlightRect: CGRect(x: 50, y: 100, width: 300, height: 350),
                tooltipAlignment: .bottom,
                duration: nil,
                isInteractive: false
            ),
            
            // 6. Recruit College Students (navigate to resources for next step)
            TutorialStep(
                title: "Recruit & Build Your College Team",
                description: "Find talented college students to join your startup",
                targetView: "circles_tab",
                message: "Recruit and build a team for your business with other college students on the platform. Find students with complementary skills, shared entrepreneurial drive, and the flexibility that comes with being in school. Your next co-founder or key team member might be just a few dorms away!",
                navigationDestination: "PageEntrepreneurResources", // Navigate to resources for next step
                highlightRect: CGRect(x: 100, y: 200, width: 280, height: 300),
                tooltipAlignment: .leading,
                duration: nil,
                isInteractive: false
            ),
            
            // 7. Skill Development Focus (navigate to profile for next step)
            TutorialStep(
                title: "Develop Entrepreneurial Skills",
                description: "Learn practical skills from experienced professionals",
                targetView: "professional_services",
                message: "Access resources to learn about startup legal basics, financial planning, marketing, and more. Many professionals offer educational content specifically designed for aspiring entrepreneurs.",
                navigationDestination: "ProfilePage", // Navigate to profile for next step
                highlightRect: CGRect(x: 50, y: 200, width: 300, height: 200),
                tooltipAlignment: .bottom,
                duration: nil,
                isInteractive: false
            ),
            
            // 8. Building Your Profile (navigate to messages for next step)
            TutorialStep(
                title: "Build Your Entrepreneurial Profile",
                description: "Start building your professional presence while still in school",
                targetView: "profile_tab",
                message: "Even as a student, showcase your projects, internships, and entrepreneurial interests. This helps mentors understand your goals and attracts like-minded student entrepreneurs.",
                navigationDestination: "PageMessages", // Navigate to messages for next step
                highlightRect: CGRect(x: 320, y: 150, width: 250, height: 300),
                tooltipAlignment: .top,
                duration: nil,
                isInteractive: false
            ),
            
            // 9. Networking Strategy (navigate to forum for final step)
            TutorialStep(
                title: "Student Networking Strategy",
                description: "Learn how to network effectively as a student",
                targetView: "messages_tab",
                message: "When reaching out to entrepreneurs, be genuine about being a student. Ask thoughtful questions, show you've done your research, and offer to help with small tasks. Authenticity beats perfection!",
                navigationDestination: "PageForum", // Navigate to forum for final step
                highlightRect: CGRect(x: 60, y: 100, width: 280, height: 400),
                tooltipAlignment: .trailing,
                duration: nil,
                isInteractive: false
            ),
            
            // 10. Future Planning (already on PageForum)
            TutorialStep(
                title: "Plan Your Entrepreneurial Future",
                description: "Use Circl to explore different entrepreneurial paths",
                targetView: "success_tips",
                message: "Explore different industries, talk to founders in various stages, and understand different business models. This exploration phase is crucial for finding what truly excites you!",
                navigationDestination: nil, // Already on PageForum from previous step
                highlightRect: nil,
                tooltipAlignment: .center,
                duration: nil,
                isInteractive: false
            )
        ]
        
        return TutorialFlow(
            userType: .studentEntrepreneur,
            title: "Student Entrepreneur's Guide to Circl",
            description: "Learn how to use Circl to build your entrepreneurial knowledge and network while studying",
            steps: steps + [createTutorialAccessStep(), createFinalCommunityStep()],
            estimatedDuration: 12 * 60, // 12 minutes (10 steps + tutorial access + final step)
            isRequired: true
        )
    }
    
    // MARK: - Community Builder Tutorial Flow  
    func createCommunityBuilderTutorial() -> TutorialFlow {
        let steps = [
            TutorialStep(
                title: "Welcome Community Builder!",
                description: "Learn how to create and manage thriving professional communities",
                targetView: "main_navigation",
                message: "Not only will you have tools to manage your community, Circl actually provides the ecosystem for them to build on their goals. You're not just building a community, you're making that impact.",
                navigationDestination: "PageForum", // Navigate to forum for next step
                highlightRect: nil,
                tooltipAlignment: .center,
                duration: nil,
                isInteractive: false
            ),
            
            TutorialStep(
                title: "Your Brand Canvas",
                description: "Engage with the community with valuable content and updates",
                targetView: "home_tab",
                message: "Be seen by the users, doing so will improve your chances of them joining your community!",
                navigationDestination: "PageUnifiedNetworking", // Navigate to network for next step
                highlightRect: CGRect(x: 50, y: 100, width: 300, height: 400),
                tooltipAlignment: .bottom,
                duration: nil,
                isInteractive: false
            ),
            
            TutorialStep(
                title: "Build Your Professional Network",
                description: "Connect with other community builders and potential members",
                targetView: "network_tab",
                message: "Network with other successful community builders, find potential community members, and learn best practices for community management and growth.",
                navigationDestination: "PageCircles", // Navigate to circles for next step
                highlightRect: CGRect(x: 80, y: 150, width: 250, height: 350),
                tooltipAlignment: .top,
                duration: nil,
                isInteractive: true
            ),
            
            TutorialStep(
                title: "Create and Manage Circles",
                description: "Build multiple communities around different topics and interests",
                targetView: "circles_tab",
                message: "Create circles for different professional groups, industries, or interests. Use advanced moderation tools, analytics, and engagement features to build thriving communities. Consider creating subscription packages with different benefits for your community members if you want to monetize your community.",
                navigationDestination: nil, // Stay on PageCircles for step 5
                highlightRect: CGRect(x: 160, y: 150, width: 250, height: 300),
                tooltipAlignment: .top,
                duration: nil,
                isInteractive: false
            ),
            
            // Step 5: Business Dashboard Feature (already on PageCircles)
            TutorialStep(
                title: "The Circle's Feature is Not Just a Community Feature",
                description: "You can create a private/public dashboard to run your business",
                targetView: "success_tips",
                message: "Track your KPIs, tasks, and more in the dashboard. Not only is the Circle's feature made to create communities, but you can also create one to run your company, invite your coworkers or employees and build together. The future is yours, build it!",
                navigationDestination: nil, // Stay on PageCircles for final step
                highlightRect: nil,
                tooltipAlignment: .center,
                duration: nil,
                isInteractive: false
            )
        ]
        
        return TutorialFlow(
            userType: .communityBuilder,
            title: "Community Builder's Guide to Circl",
            description: "Master the art of building and managing professional communities",
            steps: steps + [createTutorialAccessStep(), createFinalCommunityStep()], // Tutorial access + final community step
            estimatedDuration: 7 * 60, // 7 minutes (5 steps + tutorial access + final community step)
            isRequired: true
        )
    }
    
    // MARK: - Investor Tutorial Flow
    func createInvestorTutorial() -> TutorialFlow {
        let steps = [
            TutorialStep(
                title: "Welcome to Circl, Investor!",
                description: "Discover quality startups and connect with promising founders",
                targetView: "main_navigation",
                message: "As an investor, you need deal flow, due diligence insights, and direct access to founders. Circl provides a curated community of serious entrepreneurs and investors.",
                navigationDestination: "PageForum", // Navigate to forum for next step
                highlightRect: nil,
                tooltipAlignment: .center,
                duration: nil,
                isInteractive: false
            ),
            
            TutorialStep(
                title: "Scout Investment Opportunities",
                description: "Browse startup updates and founder achievements",
                targetView: "home_tab",
                message: "The home feed shows startup milestones, funding announcements, and founder insights. Great for spotting trending companies and understanding market dynamics before making investment decisions.",
                navigationDestination: "PageUnifiedNetworking", // Navigate to network for next step
                highlightRect: CGRect(x: 50, y: 100, width: 300, height: 400),
                tooltipAlignment: .bottom,
                duration: nil,
                isInteractive: false
            ),
            
            TutorialStep(
                title: "Direct Founder Access",
                description: "Connect directly with founders seeking investment",
                targetView: "network_tab",
                message: "Skip the pitch deck emails. Connect directly with founders, ask questions, and evaluate opportunities.",
                navigationDestination: "PageCircles", // Navigate to circles for next step
                highlightRect: CGRect(x: 80, y: 150, width: 250, height: 350),
                tooltipAlignment: .top,
                duration: nil,
                isInteractive: true
            ),
            
            TutorialStep(
                title: "Join Investor Circles",
                description: "Connect with other investors and share deal flow",
                targetView: "circles_tab",
                message: "Join investor-focused circles to share due diligence insights, co-invest in deals, and learn from experienced VCs and angels. Collaboration often leads to better investment outcomes.",
                navigationDestination: nil, // Stay on circles for next step
                highlightRect: CGRect(x: 160, y: 150, width: 250, height: 300),
                tooltipAlignment: .top,
                duration: nil,
                isInteractive: false
            ),
            
            TutorialStep(
                title: "Create Your Investment Circle",
                description: "Build a community with your founders and portfolio companies",
                targetView: "circles_tab",
                message: "Create a circle to build a community with your founders or even run your own personal investment company through Circl. This allows you to maintain ongoing relationships with your portfolio companies and create a supportive ecosystem.",
                navigationDestination: nil, // Stay on circles for next step
                highlightRect: CGRect(x: 50, y: 100, width: 300, height: 350),
                tooltipAlignment: .bottom,
                duration: nil,
                isInteractive: false
            ),
            
            TutorialStep(
                title: "Generate Deal Flow Through Mentoring",
                description: "Become a mentor to discover early-stage opportunities",
                targetView: "circles_tab",
                message: "Get deal flow by creating a circle and becoming a mentor. Advise entrepreneurs on how to set up a business that an investor would back, and co-create this mentoring approach with other investors. This positions you to see promising deals early.",
                navigationDestination: "PageForum", // Navigate back to forum for final step
                highlightRect: CGRect(x: 100, y: 200, width: 280, height: 300),
                tooltipAlignment: .leading,
                duration: nil,
                isInteractive: false
            )
        ]
        
        return TutorialFlow(
            userType: .investor,
            title: "Investor's Guide to Deal Flow",
            description: "Use Circl to find quality investment opportunities and connect with founders",
            steps: steps + [createTutorialAccessStep(), createFinalCommunityStep()],
            estimatedDuration: 8 * 60, // 8 minutes (6 steps + tutorial access + final step)
            isRequired: true
        )
    }
    
    // MARK: - Mentor Tutorial Flow
    func createMentorTutorial() -> TutorialFlow {
        let steps = [
            TutorialStep(
                title: "Welcome to Circl, Mentor!",
                description: "Share your expertise and guide the next generation of entrepreneurs",
                targetView: "main_navigation",
                message: "Your experience is invaluable to aspiring entrepreneurs. Circl makes it easy to connect with founders who need your specific expertise and guidance.",
                navigationDestination: "PageForum", // Navigate to forum for next step
                highlightRect: nil,
                tooltipAlignment: .center,
                duration: nil,
                isInteractive: false
            ),
            
            TutorialStep(
                title: "Share Knowledge & Insights",
                description: "Contribute to the entrepreneurial community through content",
                targetView: "home_tab",
                message: "Share your experiences, lessons learned, and industry insights. Your posts help founders avoid common mistakes and make better decisions. This also helps potential mentees find you.",
                navigationDestination: "PageUnifiedNetworking", // Navigate to network for next step
                highlightRect: CGRect(x: 50, y: 100, width: 300, height: 400),
                tooltipAlignment: .bottom,
                duration: nil,
                isInteractive: false
            ),
            
            TutorialStep(
                title: "Find Mentees & Co-Create Groups",
                description: "Connect with mentees and collaborate with fellow mentors",
                targetView: "network_tab",
                message: "Find mentees or co-create mentorship groups with other mentors. Browse entrepreneurs looking for guidance in your expertise area, or team up with other mentors to create comprehensive mentorship programs.",
                navigationDestination: "PageCircles", // Navigate to circles for next step
                highlightRect: CGRect(x: 80, y: 150, width: 250, height: 350),
                tooltipAlignment: .top,
                duration: nil,
                isInteractive: true
            ),
            
            TutorialStep(
                title: "Create Your Mentorship Circle",
                description: "Build and monetize your own mentorship community",
                targetView: "circles_tab",
                message: "Create your own mentorship circle that you can monetize if you choose. Make your circle as small or as large as you think you can handle as a mentor. This gives you control over your mentorship capacity and allows you to create specialized programs.",
                navigationDestination: nil, // Stay on circles for next step
                highlightRect: CGRect(x: 50, y: 100, width: 300, height: 350),
                tooltipAlignment: .bottom,
                duration: nil,
                isInteractive: false
            ),
            
            TutorialStep(
                title: "Lead Industry Discussions",
                description: "Guide conversations in relevant circles",
                targetView: "circles_tab",
                message: "Join circles in your area of expertise and contribute to discussions. Your insights help shape the next generation of entrepreneurs and establish you as a thought leader.",
                navigationDestination: "PageMessages", // Navigate to messages for next step
                highlightRect: CGRect(x: 160, y: 150, width: 250, height: 300),
                tooltipAlignment: .top,
                duration: nil,
                isInteractive: false
            ),
            
            TutorialStep(
                title: "Mentor Through Direct Messages",
                description: "Provide personalized guidance through one-on-one conversations",
                targetView: "messages_tab",
                message: "Use messages to have deeper mentoring conversations, provide specific feedback, and build lasting mentor-mentee relationships. This personal touch makes all the difference in a founder's journey.",
                navigationDestination: "PageForum", // Navigate back to forum for final step
                highlightRect: CGRect(x: 60, y: 100, width: 280, height: 400),
                tooltipAlignment: .trailing,
                duration: nil,
                isInteractive: false
            )
        ]
        
        return TutorialFlow(
            userType: .mentor,
            title: "Mentor's Guide to Impact",
            description: "Learn how to effectively mentor and guide entrepreneurs on Circl",
            steps: steps + [createTutorialAccessStep(), createFinalCommunityStep()],
            estimatedDuration: 7 * 60, // 7 minutes (6 steps + tutorial access + final step)
            isRequired: true
        )
    }
    
    // DEPRECATED: General user type removed in favor of new 5-type system
    func createGeneralTutorial() -> TutorialFlow {
        let steps = [
            TutorialStep(
                title: "Welcome to Circl! 👋",
                description: "Your gateway to the entrepreneurial ecosystem",
                targetView: "main_navigation",
                message: "Circl connects you with entrepreneurs, investors, mentors, and business opportunities. Whether you're exploring entrepreneurship or supporting the ecosystem, there's a place for you here.",
                navigationDestination: nil,
                highlightRect: nil,
                tooltipAlignment: .center,
                duration: nil,
                isInteractive: false
            ),
            
            TutorialStep(
                title: "Explore the Community",
                description: "Discover stories, insights, and opportunities",
                targetView: "home_tab",
                message: "The home feed showcases the best of entrepreneurship - success stories, lessons learned, and opportunities. It's a great way to learn about the startup world and get inspired.",
                navigationDestination: "PageForum",
                highlightRect: CGRect(x: 50, y: 100, width: 300, height: 400),
                tooltipAlignment: .bottom,
                duration: nil,
                isInteractive: false
            ),
            
            TutorialStep(
                title: "Build Your Network",
                description: "Connect with like-minded professionals",
                targetView: "network_tab",
                message: "Whether you're looking to learn, collaborate, or explore opportunities, building meaningful connections is key. Use the network to find people who share your interests and goals.",
                navigationDestination: "PageUnifiedNetworking",
                highlightRect: CGRect(x: 80, y: 150, width: 250, height: 350),
                tooltipAlignment: .top,
                duration: nil,
                isInteractive: true
            ),
            
            TutorialStep(
                title: "Join Relevant Circles",
                description: "Find communities that match your interests",
                targetView: "circles_tab",
                message: "Circles are focused communities around specific topics, industries, or interests. Join ones that align with your goals to have deeper, more meaningful conversations.",
                navigationDestination: "PageCircles",
                highlightRect: CGRect(x: 160, y: 150, width: 250, height: 300),
                tooltipAlignment: .top,
                duration: nil,
                isInteractive: false
            )
        ]
        
        return TutorialFlow(
            userType: .other,
            title: "Getting Started with Circl",
            description: "Learn the basics of navigating and connecting on Circl",
            steps: steps + [createTutorialAccessStep(), createFinalCommunityStep()],
            estimatedDuration: 6 * 60, // 6 minutes (4 steps + tutorial access + final step)
            isRequired: true
        )
    }
    
    // MARK: - Tutorial Access Step
    private func createTutorialAccessStep() -> TutorialStep {
        return TutorialStep(
            title: "Need a Refresher?",
            description: "You can always rewatch tutorials anytime",
            targetView: "settings_tutorial_access",
            message: "Forgot how to use a feature? No worries! You can always rewatch any tutorial by going to Settings and tapping 'Start Tutorial'. All tutorials are available anytime you need them - perfect for brushing up on features or helping friends get started!",
            navigationDestination: nil,
            highlightRect: CGRect(x: 50, y: 200, width: 300, height: 150),
            tooltipAlignment: .bottom,
            duration: nil,
            isInteractive: false
        )
    }
    
    // MARK: - Universal Final Step
    private func createFinalCommunityStep() -> TutorialStep {
        return TutorialStep(
            title: "Welcome to the Circl Community!",
            description: "Thank you for joining our collaborative ecosystem",
            targetView: "community_welcome",
            message: """
            Thank you for being part of our growing community! 
            
            Circl is built on collaboration - connecting employees, students, entrepreneurs, investors, and mentors in one powerful ecosystem. The network effect is real here, and every connection you make strengthens the entire community.
            
            Ready to start collaborating? Join a Circl that matches your interests and goals. Then invite your friends, colleagues, and classmates to grow this ecosystem together!
            """,
            navigationDestination: nil,
            highlightRect: nil,
            tooltipAlignment: .center,
            duration: nil,
            isInteractive: true
        )
    }
}