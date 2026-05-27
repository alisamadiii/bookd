import Foundation

// MARK: - Sample Data

enum SampleData {

    static let me = ClientProfile(
        name: "Jordan",
        handle: "@jordan",
        avatarPalette: ["#6C5CE7", "#FFB259", "#FF6FA0"]
    )

    static let pros: [Professional] = [
        Professional(
            id: "p1", name: "Mira Okonkwo", handle: "@miracuts", category: "hair",
            role: "Hair stylist · Editorial color",
            city: "Brooklyn, NY", verified: true,
            rating: 4.97, reviews: 312, followers: "24.1k",
            palette: ["#FF7A59", "#FFB259", "#FFE0C4", "#7E5BFF"],
            bio: "Color-first stylist. Editorial, balayage, transformations. Studio in Bushwick.",
            badges: ["Top Pro", "Editorial"],
            nextSlot: "Tomorrow, 11:00 AM",
            priceRange: "$120–$420",
            services: [
                ProService(id: "s1", name: "Signature cut", price: 120, duration: 45),
                ProService(id: "s2", name: "Color refresh", price: 220, duration: 90),
                ProService(id: "s3", name: "Full balayage", price: 380, duration: 180),
                ProService(id: "s4", name: "Consultation", price: 0, duration: 20),
            ],
            posts: 18
        ),
        Professional(
            id: "p2", name: "Kenji Aroldi", handle: "@kenji.ink", category: "tattoo",
            role: "Tattoo artist · Fine line + blackwork",
            city: "Los Angeles, CA", verified: true,
            rating: 4.99, reviews: 487, followers: "88.4k",
            palette: ["#0B1538", "#3B2F87", "#B385FF", "#1C0F3E"],
            bio: "Custom only. Booking opens monthly. Single needle specialist.",
            badges: ["Top Pro", "Booked out"],
            nextSlot: "Apr 14, 2:00 PM",
            priceRange: "$280–$1.2k",
            services: [
                ProService(id: "s1", name: "Small fine line (≤2hr)", price: 320, duration: 120),
                ProService(id: "s2", name: "Medium piece", price: 680, duration: 240),
                ProService(id: "s3", name: "Full sleeve session", price: 1200, duration: 360),
            ],
            posts: 42
        ),
        Professional(
            id: "p3", name: "Sara Lindgren", handle: "@sara.lift", category: "fitness",
            role: "Strength coach · Postpartum specialist",
            city: "Austin, TX", verified: true,
            rating: 4.92, reviews: 198, followers: "11.2k",
            palette: ["#7AE582", "#0BBFA2", "#FFD86B", "#0F4D3F"],
            bio: "PT, RPS — building strong, calm bodies. In-person + remote.",
            badges: ["Verified", "Online"],
            nextSlot: "Today, 4:30 PM",
            priceRange: "$60–$180",
            services: [
                ProService(id: "s1", name: "Discovery call", price: 0, duration: 20),
                ProService(id: "s2", name: "Single session", price: 120, duration: 60),
                ProService(id: "s3", name: "4-week program", price: 480, duration: 60),
            ],
            posts: 24
        ),
        Professional(
            id: "p4", name: "Aaliyah Reyes", handle: "@aaliyah.beauty", category: "beauty",
            role: "Makeup artist · Bridal + editorial",
            city: "Miami, FL", verified: true,
            rating: 4.95, reviews: 261, followers: "32.6k",
            palette: ["#FFCED0", "#FF6FA0", "#FFE7A8", "#A93665"],
            bio: "Soft glam. Bridal trials by appointment.",
            badges: ["Editorial"],
            nextSlot: "Fri, 9:00 AM",
            priceRange: "$150–$650",
            services: [
                ProService(id: "s1", name: "Bridal trial", price: 220, duration: 75),
                ProService(id: "s2", name: "Bridal day-of", price: 650, duration: 120),
                ProService(id: "s3", name: "Event glam", price: 220, duration: 60),
            ],
            posts: 31
        ),
        Professional(
            id: "p5", name: "Dr. Noor Hadid", handle: "@noor.wellness", category: "wellness",
            role: "Acupuncturist · Cupping + herbal",
            city: "San Francisco, CA", verified: true,
            rating: 4.98, reviews: 174, followers: "6.8k",
            palette: ["#C7E4C2", "#A4B98A", "#F0EEDB", "#384E2B"],
            bio: "TCM clinic, 12 years practice. Anxiety, sleep, fertility.",
            badges: ["Verified"],
            nextSlot: "Thu, 10:30 AM",
            priceRange: "$95–$220",
            services: [
                ProService(id: "s1", name: "Initial consult", price: 220, duration: 90),
                ProService(id: "s2", name: "Follow-up", price: 130, duration: 50),
                ProService(id: "s3", name: "Cupping add-on", price: 45, duration: 20),
            ],
            posts: 9
        ),
        Professional(
            id: "p6", name: "Theo Marchetti", handle: "@theo.shoots", category: "photo",
            role: "Photographer · Portraits + brand",
            city: "New York, NY", verified: false,
            rating: 4.89, reviews: 96, followers: "4.4k",
            palette: ["#1A1A1F", "#FF5A5F", "#FAFAFA", "#6D6DFF"],
            bio: "Editorial headshots. Studio + on-location.",
            badges: ["New"],
            nextSlot: "Sat, 1:00 PM",
            priceRange: "$280–$1.4k",
            services: [
                ProService(id: "s1", name: "Headshot mini", price: 280, duration: 45),
                ProService(id: "s2", name: "Portrait session", price: 580, duration: 120),
                ProService(id: "s3", name: "Brand shoot (half-day)", price: 1400, duration: 240),
            ],
            posts: 22
        ),
    ]

    static let mePro: Professional = pros[0]

    static let reviews: [ProReview] = [
        ProReview(id: "r1", author: "Sasha M.", rating: 5, when: "2d ago",
                  text: "Best color I've ever had. Mira nailed exactly what I asked for and the studio is gorgeous.",
                  avatarPalette: ["#FFB259", "#FF6FA0"]),
        ProReview(id: "r2", author: "Devon K.", rating: 5, when: "1w ago",
                  text: "Booked last-minute, got a slot in 2 hours. Came out looking incredible.",
                  avatarPalette: ["#7AE582", "#0BBFA2"]),
        ProReview(id: "r3", author: "Priya A.", rating: 4, when: "2w ago",
                  text: "Loved the cut. Slightly long wait but worth it.",
                  avatarPalette: ["#B385FF", "#3B2F87"]),
        ProReview(id: "r4", author: "Mike T.", rating: 5, when: "3w ago",
                  text: "My partner came home glowing — literally. Booking again.",
                  avatarPalette: ["#FFCED0", "#A93665"]),
    ]

    static let appointments: [Appointment] = [
        Appointment(id: "a1", proId: "p1", service: "Color refresh", date: "Tomorrow", time: "11:00 AM",
                    duration: 90, price: 220, status: .upcoming, location: "247 Wilson Ave, Brooklyn"),
        Appointment(id: "a2", proId: "p3", service: "Single session", date: "Sat, Apr 12", time: "4:30 PM",
                    duration: 60, price: 120, status: .upcoming, location: "Eastside Gym, Austin"),
        Appointment(id: "a3", proId: "p4", service: "Event glam", date: "Mar 28", time: "6:00 PM",
                    duration: 60, price: 220, status: .past, location: "On-location"),
        Appointment(id: "a4", proId: "p5", service: "Initial consult", date: "Mar 15", time: "10:30 AM",
                    duration: 90, price: 220, status: .past, location: "Mission St Clinic, SF"),
        Appointment(id: "a5", proId: "p2", service: "Small fine line", date: "Feb 22", time: "2:00 PM",
                    duration: 120, price: 320, status: .cancelled, location: "Echo Park Studio"),
    ]

    static let threads: [MessageThread] = [
        MessageThread(id: "t1", proId: "p1", lastMessage: "See you tomorrow at 11! Bring inspo pics 🌅", when: "14m", unread: 2),
        MessageThread(id: "t2", proId: "p3", lastMessage: "Your form check from last week looked solid.", when: "2h", unread: 0),
        MessageThread(id: "t3", proId: "p4", lastMessage: "Trial confirmed. Sent care guide via email.", when: "Yesterday", unread: 0),
        MessageThread(id: "t4", proId: "p2", lastMessage: "Wait list slot opened up. Apr 14 still good?", when: "Mon", unread: 1),
        MessageThread(id: "t5", proId: "p6", lastMessage: "Studio confirmed, parking instructions attached.", when: "Mar 30", unread: 0),
    ]

    static let chatMessages: [ChatMessage] = [
        ChatMessage(id: "m1", fromMe: false, text: "Hey Jordan! Excited for tomorrow ✨", when: "10:24 AM"),
        ChatMessage(id: "m2", fromMe: true, text: "Same! Should I come with hair washed?", when: "10:28 AM"),
        ChatMessage(id: "m3", fromMe: false, text: "Day-old is best. Bring any inspo pics you have!", when: "10:30 AM"),
        ChatMessage(id: "m4", fromMe: true, text: "On it. See you at 11.", when: "10:31 AM"),
        ChatMessage(id: "m5", fromMe: false, text: "See you tomorrow at 11! Bring inspo pics 🌅", when: "14m ago"),
    ]

    static let proStats = ProStats(
        todayBookings: 4,
        weekEarnings: 2840,
        monthEarnings: 11240,
        profileViews: 1284,
        bookingRate: 18.4,
        todaySchedule: [
            ScheduleEntry(time: "9:00 AM", client: "Naomi B.", service: "Signature cut", duration: 45),
            ScheduleEntry(time: "10:30 AM", client: "Jordan", service: "Color refresh", duration: 90),
            ScheduleEntry(time: "1:00 PM", client: "Mae L.", service: "Full balayage", duration: 180),
            ScheduleEntry(time: "4:30 PM", client: "Riley T.", service: "Signature cut", duration: 45),
        ]
    )

    static let calendarBlocks: [CalendarBlock] = [
        CalendarBlock(hour: 9, span: 0.75, name: "Naomi B.", service: "Signature cut", color: "#FFCED0"),
        CalendarBlock(hour: 10.5, span: 1.5, name: "Jordan M.", service: "Color refresh", color: "#B385FF"),
        CalendarBlock(hour: 13, span: 3, name: "Mae L.", service: "Full balayage", color: "#FFB259"),
        CalendarBlock(hour: 16.5, span: 0.75, name: "Riley T.", service: "Signature cut", color: "#7AE582"),
    ]

    static func makePortfolio(for pro: Professional, count: Int = 9) -> [PortfolioPost] {
        let captions = ["Fresh today", "Custom", "New work", "Studio session", "Client + me", "Bridal trial", "Open booking"]
        return (0..<count).map { i in
            PortfolioPost(
                id: "\(pro.id)-post-\(i)",
                caption: captions[i % captions.count],
                likes: 100 + ((i * 73) % 900),
                seed: i + 1
            )
        }
    }

    static func pro(for id: String) -> Professional? {
        pros.first { $0.id == id }
    }
}
