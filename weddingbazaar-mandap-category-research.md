# WeddingBazaar + Mandap.com Category Research

## Scope

This document captures the **real listing and detail patterns** observed on WeddingBazaar and Mandap.com and maps them to a **GoMandap-ready category schema**.

### Sources reviewed
- WeddingBazaar homepage, venue listings, and category pages
- Mandap.com homepage, venue listings, and venue-type pages
- Current GoMandap app taxonomy already present in the Android UI and filter models

---

## 1. What the competitors are doing well

### WeddingBazaar
- Strong **category-first discovery** across many wedding services
- Clear **city + category + budget** intent on homepage and category pages
- Listing cards emphasize:
  - price
  - city/locality
  - rating
  - bookings / shortlist
  - availability / check availability
  - parking / capacity / amenity snippets
- Venue detail pages emphasize:
  - pricing
  - amenities
  - payment policy
  - “why choose us”
  - user feedback and reviews
  - service summary and contact CTA

### Mandap.com
- Strong **venue-type taxonomy** and **smart filtering**
- Listing cards emphasize:
  - per-day pricing
  - hall capacity
  - parking
  - room count
  - AC
  - availability and phone number CTA
- Venue detail pages emphasize:
  - verified / premium status
  - amenities
  - booking and contact flow
  - transparent pricing
  - assistant / support assistance

---

## 2. GoMandap category map

The current GoMandap app already supports a premium mobile-first version of the following categories:

1. Venues
2. Photography
3. Makeup
4. Decor / Mandap
5. Catering

A full WeddingBazaar-style product catalog should add the following categories as well:

6. Mehndi Artists
7. Invitations / Cards
8. Jewellery
9. DJ & Live Music
10. Bridal Designers / Wedding Wear
11. Cars
12. Entertainment
13. Choreographers
14. Gifts
15. Pandits
16. Honeymoon / Travel
17. Wedding Planners

---

## 3. Common listing card structure

### Shared listing metadata for every category

| Field | Purpose | Notes |
| --- | --- | --- |
| Vendor / business name | Identity | Always visible |
| City / locality | Discovery | Most important local signal |
| Rating | Trust | Include stars and review count |
| Price | Conversion | Per day / per plate / per session / package |
| Category badge | Context | Example: Venue, Photographer, Decorator |
| Shortlist / save | Retention | Save for later |
| Availability CTA | Conversion | “Check availability”, “View contact”, “Book now” |
| Verified / preferred badge | Trust | Similar to WeddingBazaar preferred vendor |
| Supporting highlight | Decision aid | Parking, AC, rooms, albums, packages |

### Shared detail page structure

| Section | Purpose | Recommended content |
| --- | --- | --- |
| Hero gallery | Visual first impression | 4–8 images or gallery cards |
| Header | Identity + trust | Name, city, rating, category, verified badge |
| Pricing summary | Conversion | Price type, base price, package notes |
| Why choose us | Differentiation | Business experience, events done, specialty, service guarantee |
| Services offered | Quick scan | Core services and add-ons |
| Amenities / features | Decision support | Rooms, parking, AC, backup, logistics |
| Payment policies | Trust / conversion | Deposit, milestone, cancellation |
| Other information | Eligibility | Property type, pricing model, décor restrictions, outside vendor policy |
| Key insights | Social proof | Top user-liked statements |
| About section | Brand storytelling | Vendor background / service promise |
| Albums / portfolio | Visual proof | Album count and gallery previews |
| CTA block | Final action | Book now / contact vendor / check availability |

---

## 4. Category-by-category research

## 4.1 Venues

### What WeddingBazaar shows
- Filters visible on venue pages:
  - City
  - Capacity
  - Budget - Per Day
  - Budget - Per Plate
  - Food Type
  - Ratings
  - Venue Amenities
  - Catering Policies
  - Shortlisted
- Listing cards show:
  - price
  - locality
  - rating
  - parking
  - hall capacity
  - availability CTA
  - shortlist

### What Mandap.com shows
- Filters and categories are organized around venue types such as:
  - Resorts
  - Banquet Halls
  - Premium Venues
  - Seaside Venues
  - Farm Houses
  - Convention Halls
  - Kalyana Mandapams
  - Destination Weddings
  - Lawns
  - 5 Star Hotels
  - 4 Star Hotels
  - Mini Halls
  - Forts and Palaces
- Listing cards show:
  - price
  - hall capacity
  - parking
  - AC
  - rooms
  - check availability
  - phone number CTA

### Recommended venue filters

| Filter | Type | Notes |
| --- | --- | --- |
| City / locality | Multi-select | Mandatory |
| Venue type | Multi-select | Banquet hall, lawn, resort, palace, hotel, kalyana mandapam |
| Capacity | Range | Guest capacity |
| Budget type | Toggle | Per day / per plate |
| Price range | Range | Based on pricing model |
| Ratings | Slider / chips | 4.0+, 4.5+, 4.8+ |
| Outdoor / indoor | Toggle | Critical for event style |
| AC | Toggle | High-value filter |
| Rooms available | Toggle / range | Useful for guest stay |
| Parking | Range | Car parking count |
| Backup power | Toggle | Good premium signal |
| Bridal room | Toggle | Useful for marraige logistics |
| Outside decor allowed | Toggle | Important policy field |
| Outside catering allowed | Toggle | Critical for food decisions |
| Outside DJ allowed | Toggle | Important policy field |
| Alcohol allowed | Toggle | Important policy field |
| Valet parking | Toggle | Premium filter |
| Food type | Toggle | Veg / non-veg / both |
| Preferred category | Toggle | Preferred vendor / shortlist |

### Venue detail fields

| Field | Notes |
| --- | --- |
| Name | Venue name |
| City / locality | Location |
| Rating | Numeric + label |
| Pricing | Per day / per plate |
| Event area count | Number of available areas |
| Services offered | List of wedding-related services |
| Why choose us | Business experience + events done |
| Albums | Count + preview images |
| Amenities | Rooms, AC rooms, parking, backup, bridal room |
| Payment policy | Booking %, on-date %, post-event %, cancellation |
| Other information | Property type, pricing model, décor, DJ, food, alcohol, valet parking, cuisine |
| Key insights / user feedback | What users liked |
| About | Story / location / access / guest convenience |

### Example: Tharaga Mahal

Use the following as the sample venue detail blueprint:

- Name: Tharaga Mahal
- City: Coimbatore
- Rating: 4.5
- Review label: Good
- Price: ₹2,00,000
- Price type: Per Day
- Event areas: 1
- Services offered: Not explicitly shown in the sample; add placeholder/service list
- Why choose us:
  - 6 years in business
  - 120 events done
- Albums:
  - Stage / Mandap Close-up
  - Catering / Dining
  - Exterior / Facade & Entrance
  - Main Hall / Set Up
- Venue amenities:
  - 6 rooms available
  - 6 AC rooms
  - 10 parking
  - electricity backup
  - bridal room
  - parking
- Payment policy:
  - 50% on booking
  - 50% on date
  - 0% after event
  - Non-refundable cancellation
- Other information:
  - property type: Kalyana Mandapam
  - price type: Time Based Rent
  - decoration: Outside decorators allowed
  - DJ: Outside DJ allowed
  - food: Outside food allowed
  - alcohol: Outside alcohol not allowed
  - valet parking: Yes
  - allowed cuisine: Both
- Key insights:
  - Best in budget
  - Very professional
  - Good service and time management
- About:
  - Easy commuting, spacious, parking, contact through Mandap.com team

---

## 4.2 Photography

### Recommended filters

| Filter | Notes |
| --- | --- |
| City / locality | Mandatory |
| Style | Cinematic, candid, traditional, drone, pre-wedding |
| Budget | Per day / per event |
| Deliverables | Albums, teaser, raw footage |
| Team size | Small / standard / large |
| Full wedding package | Toggle |
| Outstation travel | Toggle |
| Ratings | Slider |

### Recommended detail fields

| Field | Notes |
| --- | --- |
| Portfolio styles | List of photography styles |
| Price | Per day / package |
| Delivery timeline | Weeks |
| Extra deliverables | Albums, reels, raw footage |
| Team size | Number of photographers |
| Travel policy | Local / outstation |
| Sample album count | Number of albums |

---

## 4.3 Bridal Makeup Artists

### Recommended filters

| Filter | Notes |
| --- | --- |
| City / locality | Mandatory |
| Budget | Per session / bridal package |
| Makeup type | Airbrush, HD, regular bridal |
| Hair styling | Included / optional |
| Draping | Included / optional |
| Paid trial | Toggle |
| Brand | MAC, Huda, Kryolan, Chanel |
| Ratings | Slider |

### Recommended detail fields

| Field | Notes |
| --- | --- |
| Makeup style | Airbrush / HD / regular |
| Price | Per session / package |
| Hair styling | Included or not |
| Trial availability | Yes / no |
| Portfolio / before-after | Images |
| Service count | Number of bookings |

---

## 4.4 Decorators / Mandap Decor

### Recommended filters

| Filter | Notes |
| --- | --- |
| City / locality | Mandatory |
| Theme | Floral, acrylic, traditional, royal, boho |
| Setup location | Indoor / outdoor / both |
| Budget | Package budget |
| Components | Mandap, stage, entrance, AV, lighting |
| Ratings | Slider |
| Outdoor setup | Toggle |

### Recommended detail fields

| Field | Notes |
| --- | --- |
| Decor theme | Floral / acrylic / royal / boho |
| Setup area size | Dimensions |
| Setup time | Hours |
| Components offered | Stage, mandap, floral, entrance, lighting |
| Outside decorators allowed | Policy |
| Install / teardown time | Important for execution |

---

## 4.5 Catering

### Recommended filters

| Filter | Notes |
| --- | --- |
| City / locality | Mandatory |
| Budget | Per plate |
| Cuisine | South Indian, North Indian, Continental, pan-Asian |
| Dietary type | Veg, non-veg, Jain |
| Service style | Buffet, banana leaf, live counters |
| Welcome drinks | Included / not included |
| Sweets buffet | Included / not included |
| Ratings | Slider |

### Recommended detail fields

| Field | Notes |
| --- | --- |
| Cuisine list | Cuisine types |
| Price per plate | Explicit |
| Min guest count | Useful for sizing |
| Service style | Buffet / live counters |
| Menu highlights | Must-have selection |
| Fresh / custom menu | Yes / no |

---

## 4.6 Mehndi Artists

### Recommended filters

| Filter | Notes |
| --- | --- |
| City / locality | Mandatory |
| Budget | Per hand / package |
| Design style | Traditional / modern / Arabic / bridal |
| Ratings | Slider |
| Experience | Years |

### Recommended detail fields

| Field | Notes |
| --- | --- |
| Design style | Traditional / modern |
| Price | Per hand / full bridal package |
| Portfolio | Designs and samples |
| Experience | Years |

---

## 4.7 Invitations / Cards

### Recommended filters

| Filter | Notes |
| --- | --- |
| City / locality | Mandatory |
| Budget | Per card / package |
| Style | Traditional, modern, minimalist, luxury |
| Printing type | Digital, letterpress, foil, handmade |
| Delivery time | Days |
| Customization | Yes / no |

### Recommended detail fields

| Field | Notes |
| --- | --- |
| Card styles | Theme / format |
| Printing options | Foil, embossing, digital |
| Turnaround time | Days |
| Sample kits | Available / not available |

---

## 4.8 Jewellery

### Recommended filters

| Filter | Notes |
| --- | --- |
| City / locality | Mandatory |
| Budget | Range |
| Collection type | Wedding sets, traditional, modern |
| Design style | Temple, kundan, polki, gold, diamond |
| Customization | Toggle |
| Ratings | Slider |

### Recommended detail fields

| Field | Notes |
| --- | --- |
| Design style | Collection theme |
| Price range | From / to |
| Customization | Available / not available |
| Certification | Hallmark / stone certification |

---

## 4.9 DJ & Live Music

### Recommended filters

| Filter | Notes |
| --- | --- |
| City / locality | Mandatory |
| Budget | Package |
| Music genre | Bollywood, fusion, live band, DJ |
| Sound system | Included / not included |
| Lighting | Included / not included |
| Event duration | Hours |
| Ratings | Slider |

### Recommended detail fields

| Field | Notes |
| --- | --- |
| Music style | DJ / band / live singers |
| Setup and sound | Included or extra |
| Duration | Hours |
| Event type | Wedding / reception / sangeet |

---

## 4.10 Bridal Designers / Wedding Wear

### Recommended filters

| Filter | Notes |
| --- | --- |
| City / locality | Mandatory |
| Budget | Per outfit / package |
| Style | Traditional, contemporary, fusion |
| Customization | Toggle |
| fitting timeline | Weeks |
| Ratings | Slider |

### Recommended detail fields

| Field | Notes |
| --- | --- |
| Outfit categories | Lehenga, saree, gown, sherwani |
| Customization | Tailor-made / curated |
| Delivery timeline | Weeks |
| Trial availability | Yes / no |

---

## 4.11 Cars

### Recommended filters

| Filter | Notes |
| --- | --- |
| City / locality | Mandatory |
| Budget | Rental package |
| Car type | Vintage, luxury, standard |
| Chauffeur | Included / not included |
| Duration | Hours / days |
| Ratings | Slider |

### Recommended detail fields

| Field | Notes |
| --- | --- |
| Car model / type | Luxury / vintage |
| Package duration | Hours / days |
| Chauffeur | Included or not |
| Route / outstation | Local / long-distance |

---

## 4.12 Entertainment

### Recommended filters

| Filter | Notes |
| --- | --- |
| City / locality | Mandatory |
| Budget | Package |
| Type | Magicians, performers, fire shows, games |
| Audience size | Small / medium / large |
| Ratings | Slider |

### Recommended detail fields

| Field | Notes |
| --- | --- |
| Entertainment type | Performer category |
| Duration | Hours |
| Audience capacity | Number of guests |
| Add-ons | Photo booth, confetti, games |

---

## 4.13 Choreographers

### Recommended filters

| Filter | Notes |
| --- | --- |
| City / locality | Mandatory |
| Budget | Package |
| Dance style | Bollywood, folk, sangeet, contemporary |
| Experience | Years |
| Sessions | Number of practice sessions |
| Ratings | Slider |

### Recommended detail fields

| Field | Notes |
| --- | --- |
| Dance style | Bollywood / folk / contemporary |
| Sessions offered | Number of sessions |
| Experience | Years |
| Repertoire | Choreography style |

---

## 4.14 Gifts

### Recommended filters

| Filter | Notes |
| --- | --- |
| City / locality | Mandatory |
| Budget | Per set /
| Gift type | Favors, hampers, personalized gifts |
| Customization | Toggle |
| Delivery | Local / pan-India |
| Ratings | Slider |

### Recommended detail fields

| Field | Notes |
| --- | --- |
| Gift category | Hampers / favors / luxury gifts |
| Personalization | Available / not available |
| Delivery timeline | Days |
| Packaging style | Theme-based |

---

## 4.15 Pandits

### Recommended filters

| Filter | Notes |
| --- | --- |
| City / locality | Mandatory |
| Language | Tamil, Telugu, Kannada, Hindi, Malayalam |
| Ritual type | Wedding, pooja, ghar priest |
| Experience | Years |
| Booking mode | In-person / online |
| Ratings | Slider |

### Recommended detail fields

| Field | Notes |
| --- | --- |
| Language | Supported languages |
| Rituals handled | List |
| Experience | Years |
| Availability | Dates |

---

## 4.16 Honeymoon / Travel

### Recommended filters

| Filter | Notes |
| --- | --- |
| City / locality | Mandatory |
| Budget | Package |
| Destination | Domestic / international |
| Travel style | Luxury, budget, adventure |
| Duration | Days |
| Ratings | Slider |

### Recommended detail fields

| Field | Notes |
| --- | --- |
| Destination | City / country |
| Duration | Days |
| Package type | Luxury / budget |
| Inclusions | Stay, transfers, meals, tours |

---

## 4.17 Wedding Planners

### Recommended filters

| Filter | Notes |
| --- | --- |
| City / locality | Mandatory |
| Budget | Package |
| Event size | Intimate / medium / large |
| Planning style | Full planning / partial / day-of |
| Experience | Years |
| Ratings | Slider |

### Recommended detail fields

| Field | Notes |
| --- | --- |
| Planning scope | Full / partial / day-of |
| Event size handled | Intimate to mega weddings |
| Portfolio | Past weddings |
| Team size | Number of planners |

---

## 5. Shared CTA and booking guidance

### Recommended call-to-actions by category

| Category | Primary CTA | Secondary CTA |
| --- | --- | --- |
| Venues | Check availability | View contact |
| Photography | View portfolio | Book date |
| Makeup | Book trial | View portfolio |
| Decor | Request quote | View gallery |
| Catering | Request menu | Check minimum guest count |
| Mehndi | View portfolio | Book artist |
| Invitations | Request sample | Customize design |
| Jewellery | View collection | Request quote |
| DJ | Request demo | Check availability |
| Bridal wear | Book fitting | View collection |
| Cars | Check package | Book chauffeur |
| Entertainment | Request demo | Check availability |
| Choreographers | Book session | View demo |
| Gifts | Customize order | Request quote |
| Pandits | Check availability | View rituals |
| Honeymoon | View itinerary | Request quote |
| Planners | Request consultation | View packages |

---

## 6. Minimal data model for all categories

### Common vendor fields

- id
- name
- category
- city
- locality
- rating
- review_count
- price
- price_label
- description
- service_tags
- gallery_urls
- verified
- preferred
- shortlist_count
- phone_number
- availability_status

### Category-specific add-ons

- Venues: capacity, parking, rooms, AC, backup_power, bridal_room, outside_dj, outside_catering, outside_decor, alcohol_policy, payment_policy
- Photography: styles, deliverables, team_size, travel_policy, delivery_time
- Makeup: makeup_types, hair_styling, draping, trial_available, brand
- Decor: theme, setup_location, components, setup_time
- Catering: cuisines, dietary_rules, service_style, min_guest_count
- Mehndi: design_style, package_type
- Invitations: printing_type, turnaround_days
- Jewellery: collection_type, customization
- DJ: music_genres, sound_system, lighting
- Bridal wear: style, customization, fitting_timeline
- Cars: car_type, chauffeur, duration
- Entertainment: performance_type, audience_size
- Choreographers: dance_style, session_count
- Gifts: gift_type, customization, delivery_mode
- Pandits: language, ritual_type
- Honeymoon: destination, duration, inclusions
- Planners: planning_scope, event_size, team_size

---

## 7. Suggested GoMandap implementation plan

1. Create a **global category schema** using this document as the source of truth.
2. Add **per-category filter models** in the Android app.
3. Add **detail page sections** based on the shared detail template.
4. Create a **mock dataset** for all categories using local sample content.
5. Keep the **venue experience** first, then expand to the other categories using the same structure.

---

## 8. Best-practice UX notes

- Favor **one-tap category discovery** with a strong hero and compact chips.
- Keep **price and trust signals** visible on every listing card.
- Use **booking / availability CTA** on every detail page.
- Show **policies clearly** so users understand what is included and what is not.
- Use **review insight snippets** such as “Best in budget”, “Very professional”, “Good service & time management”.
- Support **shortlist / save** early because both WeddingBazaar and Mandap.com use this behavior heavily.

---

## 9. Tharaga Mahal aligned detail snapshot

```yaml
vendor:
  name: Tharaga Mahal
  city: Coimbatore
  rating: 4.5
  review_label: Good
  price: 200000
  price_type: Per Day
  event_areas: 1
  services_offered: []
  why_choose_us:
    - 6 years in business
    - 120 events done
  albums:
    - Stage / Mandap Close-up
    - Catering / Dining
    - Exterior / Facade & Entrance
    - Main Hall / Set Up
  amenities:
    - 6 rooms available
    - 6 AC rooms
    - 10 parking
    - electricity backup
    - bridal room
  payment_policy:
    - 50% payment on booking
    - 50% payment on date
    - 0% payment after event
    - cancellation: Non-refundable
  other_information:
    - property type: Kalyana Mandapam
    - price type: Time Based Rent
    - decoration: Outside decorators allowed
    - dj: Outside DJ allowed
    - food: Outside food allowed
    - alcohol policy: Outside alcohol not allowed
    - valet parking: Yes
    - allowed cuisine: Both
  key_insights:
    - Best in budget
    - Very professional
    - Good service & time management
  about: |
    We are from Coimbatore and provide a spacious, accessible venue with excellent parking and a clear booking process.
```

---

## 10. Final recommendation

The current GoMandap app should implement the **venue experience first**, using this document as the canonical source for:
- filters
- listing card data
- detail page content
- category expansion

After the venue flow is stable, the same structure can be reused for photography, makeup, decorators, catering, and the remaining WeddingBazaar categories.
