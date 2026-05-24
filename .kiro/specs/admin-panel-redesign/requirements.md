# Requirements Document

## Introduction

Comprehensive redesign and expansion of the GoMandap Admin Panel — the central control console for managing India's wedding/event management marketplace. This overhaul enhances the existing scrollable dashboard with real-time data, charts, and quick-action cards while adding professional-grade modules for event operations, push notifications, revenue analytics, dispute resolution, and platform configuration. The admin panel controls both the Vendor and Client mobile apps, built with Kotlin/Jetpack Compose and Firebase Firestore.

## Glossary

- **Admin_Panel**: The Kotlin/Jetpack Compose Android application used by GoMandap operations staff to manage vendors, clients, bookings, and platform configuration
- **Dashboard**: The primary scrollable screen displaying real-time operational data, charts, quick-action cards, and module navigation
- **Event_Operations_Module**: The module providing real-time event day management including live vendor GPS tracking, SLA monitoring, backup dispatch, and event timeline management
- **Notification_System**: The subsystem responsible for sending push notifications, managing in-app announcements, and triggering automated alerts to vendors and clients
- **SLA_Engine**: The automated system that monitors vendor service-level agreements, tracks arrival times, and applies penalty or reward actions
- **Backup_Dispatch**: The mechanism for instantly assigning standby vendors to replace non-performing or absent vendors during live events
- **Escrow_Manager**: The module managing secure client funds, milestone-based payment releases, and vendor payout audits
- **Vendor_Scoring**: The system that calculates and maintains vendor performance scores based on SLA compliance, client ratings, and operational metrics
- **Revenue_Analytics**: The module providing financial reporting with daily, weekly, and monthly breakdowns of platform revenue
- **Dispute_Center**: The module for managing and resolving conflicts between clients and vendors
- **Content_Manager**: The module for managing platform banners, announcements, and featured vendor placements
- **GomandapTokens**: The design system providing color tokens (royalNavy, champagneGold, emeraldGreen, pearlWhite, slateGray), shapes, spacing, and elevation values
- **Firestore**: Firebase Cloud Firestore, the NoSQL document database serving as the backend data store
- **Admin_User**: An authorized GoMandap operations staff member with access to the Admin Panel

## Requirements

### Requirement 1: Enhanced Dashboard with Real-Time Data

**User Story:** As an Admin_User, I want a richer dashboard with real-time data, charts, and quick-action cards, so that I can monitor platform health at a glance without navigating to individual modules.

#### Acceptance Criteria

1. THE Dashboard SHALL display real-time escrow balance, active booking count, today's event count, and pending vendor approvals as summary metric cards.
2. WHEN the Dashboard loads, THE Dashboard SHALL fetch and render live data from Firestore within 3 seconds.
3. THE Dashboard SHALL display a revenue trend chart showing daily earnings for the past 7 days.
4. THE Dashboard SHALL display quick-action cards for common operations including dispatch backup vendor, send notification, and approve pending vendor.
5. WHILE an event is active today, THE Dashboard SHALL display a live event status section showing vendor arrival statuses and SLA compliance indicators.
6. WHEN a vendor triggers an SLA violation during a live event, THE Dashboard SHALL display a highlighted alert card with the vendor name, event name, and violation type.
7. THE Dashboard SHALL retain the vertically scrollable single-page layout using GomandapTokens design system colors and spacing.

### Requirement 2: Real-Time Event Operations and Live Monitoring

**User Story:** As an Admin_User, I want a dedicated event operations module with live vendor GPS tracking and event timeline management, so that I can ensure smooth event day execution.

#### Acceptance Criteria

1. THE Event_Operations_Module SHALL display a list of all events scheduled for the current day with status indicators (upcoming, in-progress, completed).
2. WHEN an Admin_User selects an active event, THE Event_Operations_Module SHALL display a live map view showing GPS positions of all assigned vendors for that event.
3. THE Event_Operations_Module SHALL display an event timeline showing scheduled milestones, actual completion times, and pending tasks for each active event.
4. WHEN a vendor's GPS position enters the event venue geofence, THE Event_Operations_Module SHALL update the vendor's arrival status to "Arrived" with a timestamp.
5. WHILE an event is in-progress, THE Event_Operations_Module SHALL refresh vendor GPS positions at intervals no longer than 30 seconds.
6. THE Event_Operations_Module SHALL allow the Admin_User to view historical event data for past events with vendor performance summaries.
7. IF a vendor has not arrived within 30 minutes of the scheduled time, THEN THE Event_Operations_Module SHALL flag the vendor as "Delayed" and display a backup dispatch prompt.

### Requirement 3: SLA Monitoring with Automated Penalty and Reward System

**User Story:** As an Admin_User, I want automated SLA monitoring with penalty and reward actions, so that vendor accountability is enforced consistently without manual intervention.

#### Acceptance Criteria

1. THE SLA_Engine SHALL track vendor arrival time, service start time, and service completion time against contracted SLA thresholds for each booking.
2. WHEN a vendor violates an SLA threshold, THE SLA_Engine SHALL automatically record the violation with timestamp, violation type, and severity level in Firestore.
3. THE SLA_Engine SHALL support configurable penalty tiers: warning, financial deduction, temporary suspension, and permanent ban.
4. WHEN a vendor accumulates 3 warnings within a 30-day period, THE SLA_Engine SHALL automatically escalate the penalty to a temporary suspension.
5. WHEN a vendor maintains 100% SLA compliance for 30 consecutive days, THE SLA_Engine SHALL apply a reward badge and priority listing boost to the vendor profile.
6. THE Admin_Panel SHALL provide a screen for the Admin_User to view all active SLA violations, filter by severity, and manually override automated penalty decisions.
7. IF the SLA_Engine cannot determine vendor arrival due to GPS signal loss, THEN THE SLA_Engine SHALL mark the status as "Unverified" and notify the Admin_User for manual review.

### Requirement 4: Instant Backup Vendor Dispatch

**User Story:** As an Admin_User, I want to instantly dispatch backup vendors when assigned vendors fail to perform, so that client events are not disrupted.

#### Acceptance Criteria

1. THE Backup_Dispatch SHALL maintain a pool of verified standby vendors categorized by service type and geographic availability.
2. WHEN an Admin_User initiates a backup dispatch, THE Backup_Dispatch SHALL display available standby vendors filtered by matching service category and proximity to the event venue.
3. WHEN a backup vendor is selected and confirmed, THE Backup_Dispatch SHALL send an immediate push notification to the backup vendor with event details, venue address, and required arrival time.
4. THE Backup_Dispatch SHALL update the event assignment record in Firestore to reflect the vendor replacement with an audit trail entry.
5. WHEN the Event_Operations_Module flags a vendor as "Delayed", THE Backup_Dispatch SHALL pre-filter eligible backup vendors and present a one-tap dispatch option to the Admin_User.
6. IF no backup vendors are available for the required service category, THEN THE Backup_Dispatch SHALL notify the Admin_User with the shortage details and suggest expanding the search radius.

### Requirement 5: Push Notification and Alerts Management

**User Story:** As an Admin_User, I want to send push notifications to vendors and clients and manage automated alerts, so that I can communicate platform updates and time-sensitive information instantly.

#### Acceptance Criteria

1. THE Notification_System SHALL allow the Admin_User to compose and send push notifications to individual vendors, individual clients, vendor groups by category, or all users.
2. THE Notification_System SHALL support notification types: informational, action-required, promotional, and emergency.
3. WHEN an Admin_User sends a notification, THE Notification_System SHALL deliver the push notification via Firebase Cloud Messaging within 5 seconds of submission.
4. THE Notification_System SHALL provide a notification history log showing sent notifications with delivery status, read receipts, and timestamps.
5. THE Notification_System SHALL support scheduled notifications that are sent at a specified future date and time.
6. THE Notification_System SHALL allow the Admin_User to create and manage in-app announcement banners visible to vendors, clients, or both.
7. WHEN an automated event triggers (SLA violation, booking confirmation, payment release), THE Notification_System SHALL send a pre-configured alert to the relevant vendor or client without manual Admin_User intervention.
8. THE Notification_System SHALL allow the Admin_User to configure automated alert templates with customizable message content and trigger conditions.

### Requirement 6: Revenue Analytics and Reporting

**User Story:** As an Admin_User, I want comprehensive revenue analytics with daily, weekly, and monthly breakdowns, so that I can track platform financial performance and identify trends.

#### Acceptance Criteria

1. THE Revenue_Analytics SHALL display total platform revenue with daily, weekly, and monthly aggregation views.
2. THE Revenue_Analytics SHALL display revenue breakdown by service category (Photography, Decor, Catering, Makeup, Banquets).
3. THE Revenue_Analytics SHALL display commission earnings, escrow holdings, and disbursed amounts as separate tracked metrics.
4. WHEN an Admin_User selects a date range, THE Revenue_Analytics SHALL generate a filtered report showing revenue, bookings count, and average booking value for that period.
5. THE Revenue_Analytics SHALL display a comparison chart showing current period performance against the previous equivalent period.
6. THE Revenue_Analytics SHALL display top-performing vendors by revenue contribution for the selected period.
7. IF Firestore data for the requested period is unavailable, THEN THE Revenue_Analytics SHALL display a data unavailability message with the last successful sync timestamp.

### Requirement 7: Client Management

**User Story:** As an Admin_User, I want to view and manage client profiles with booking history and preferences, so that I can provide personalized support and resolve issues efficiently.

#### Acceptance Criteria

1. THE Admin_Panel SHALL display a searchable and filterable list of all registered clients with name, contact information, total bookings, and account status.
2. WHEN an Admin_User selects a client profile, THE Admin_Panel SHALL display the client's complete booking history, saved preferences, and communication log.
3. THE Admin_Panel SHALL allow the Admin_User to update client account status (active, suspended, flagged) with a mandatory reason field.
4. THE Admin_Panel SHALL display client lifetime value, average booking amount, and frequency metrics on the client profile.
5. IF a client account has an active dispute, THEN THE Admin_Panel SHALL display a dispute indicator badge on the client profile card.

### Requirement 8: Vendor Performance Scoring and Ratings Management

**User Story:** As an Admin_User, I want to view vendor performance scores and manage client ratings, so that I can maintain marketplace quality standards.

#### Acceptance Criteria

1. THE Vendor_Scoring SHALL calculate a composite performance score for each vendor based on SLA compliance rate, client rating average, response time, and booking completion rate.
2. THE Admin_Panel SHALL display vendor performance scores on a leaderboard view sortable by score, category, and time period.
3. WHEN a vendor's performance score drops below a configurable threshold, THE Vendor_Scoring SHALL flag the vendor for review and notify the Admin_User.
4. THE Admin_Panel SHALL allow the Admin_User to view, approve, or remove individual client reviews and ratings for any vendor.
5. THE Admin_Panel SHALL display rating distribution charts and sentiment trends for each vendor profile.
6. WHEN an Admin_User removes a client review, THE Admin_Panel SHALL record the removal action with reason in the audit log.

### Requirement 9: Escrow Payment Management with Milestone Tracking

**User Story:** As an Admin_User, I want to manage escrow payments with milestone-based releases, so that client funds are protected and vendors are paid upon verified service delivery.

#### Acceptance Criteria

1. THE Escrow_Manager SHALL display all active escrow accounts with client name, vendor name, total amount, released amount, and pending milestones.
2. WHEN a booking milestone is marked as completed, THE Escrow_Manager SHALL present the milestone payment for Admin_User approval before releasing funds to the vendor.
3. THE Escrow_Manager SHALL display a transaction history for each escrow account showing all deposits, releases, and refunds with timestamps.
4. THE Escrow_Manager SHALL allow the Admin_User to initiate a partial or full refund to the client with a mandatory reason field.
5. IF a dispute is raised on a booking with active escrow, THEN THE Escrow_Manager SHALL freeze the pending milestone payments until the dispute is resolved.
6. THE Escrow_Manager SHALL display aggregate escrow metrics: total held funds, total released this month, and average time-to-release.

### Requirement 10: Event Calendar with Conflict Detection

**User Story:** As an Admin_User, I want an event calendar that detects scheduling conflicts, so that I can prevent double-booking of vendors and venues.

#### Acceptance Criteria

1. THE Admin_Panel SHALL display a calendar view showing all confirmed and pending bookings with event date, venue, and assigned vendors.
2. WHEN a new booking is created or modified, THE Admin_Panel SHALL check for scheduling conflicts where the same vendor is assigned to overlapping events.
3. IF a scheduling conflict is detected, THEN THE Admin_Panel SHALL display a conflict warning with details of the conflicting bookings and prevent confirmation until resolved.
4. THE Admin_Panel SHALL allow the Admin_User to filter the calendar by vendor, service category, venue, or date range.
5. WHEN an Admin_User selects a calendar date, THE Admin_Panel SHALL display all events for that date with vendor assignments and status indicators.

### Requirement 11: Dispute Resolution Center

**User Story:** As an Admin_User, I want a dedicated dispute resolution module, so that I can efficiently manage and resolve conflicts between clients and vendors.

#### Acceptance Criteria

1. THE Dispute_Center SHALL display all open disputes with client name, vendor name, booking reference, dispute category, and submission date.
2. THE Dispute_Center SHALL support dispute categories: service quality, no-show, pricing disagreement, timeline violation, and damage claim.
3. WHEN an Admin_User opens a dispute, THE Dispute_Center SHALL display the full dispute timeline including submitted evidence, communication history, and resolution attempts.
4. THE Dispute_Center SHALL allow the Admin_User to assign a resolution outcome: refund to client, payment to vendor, partial refund, or dismissed.
5. WHEN a resolution is assigned, THE Dispute_Center SHALL update the escrow status accordingly and notify both the client and vendor of the outcome.
6. THE Dispute_Center SHALL track resolution metrics: average resolution time, resolution rate, and dispute frequency by category.

### Requirement 12: Platform Settings and Configuration

**User Story:** As an Admin_User, I want centralized platform settings, so that I can configure operational parameters without code changes.

#### Acceptance Criteria

1. THE Admin_Panel SHALL provide a settings screen for configuring platform-wide parameters including commission rates, SLA thresholds, surge pricing multipliers, and penalty tiers.
2. WHEN an Admin_User modifies a platform setting, THE Admin_Panel SHALL save the change to Firestore and record the modification in the audit log with the previous value, new value, and Admin_User identity.
3. THE Admin_Panel SHALL support configuring geofence radius for vendor arrival detection.
4. THE Admin_Panel SHALL support enabling or disabling platform features (surge pricing, backup dispatch, automated penalties) via feature toggles.
5. IF a setting change affects active bookings or events, THEN THE Admin_Panel SHALL display a confirmation dialog listing the impacted items before applying the change.

### Requirement 13: Audit Logs and Activity Tracking

**User Story:** As an Admin_User, I want comprehensive audit logs, so that I can track all administrative actions for accountability and compliance.

#### Acceptance Criteria

1. THE Admin_Panel SHALL record all administrative actions (setting changes, vendor approvals, payment releases, dispute resolutions, notification sends) in an audit log with timestamp, Admin_User identity, action type, and affected entity.
2. THE Admin_Panel SHALL display audit logs in a searchable, filterable list view with date range, action type, and Admin_User filters.
3. WHEN an Admin_User views an audit log entry, THE Admin_Panel SHALL display the complete action details including before and after states where applicable.
4. THE Admin_Panel SHALL retain audit log entries for a minimum of 12 months.
5. THE Admin_Panel SHALL prevent deletion or modification of audit log entries by any Admin_User.

### Requirement 14: Promotional Offers and Discount Management

**User Story:** As an Admin_User, I want to create and manage promotional offers, so that I can drive platform engagement and bookings during specific periods.

#### Acceptance Criteria

1. THE Admin_Panel SHALL allow the Admin_User to create promotional offers with configurable parameters: discount percentage or flat amount, applicable service categories, validity period, usage limit, and minimum booking value.
2. WHEN a promotional offer is created, THE Admin_Panel SHALL store the offer in Firestore and make it available to the Client app within 60 seconds.
3. THE Admin_Panel SHALL display active, scheduled, and expired promotions with redemption count and total discount value applied.
4. THE Admin_Panel SHALL allow the Admin_User to deactivate an active promotion immediately.
5. IF a promotion reaches its usage limit, THEN THE Admin_Panel SHALL automatically deactivate the promotion and notify the Admin_User.

### Requirement 15: Review and Rating Moderation

**User Story:** As an Admin_User, I want to moderate client reviews and ratings, so that I can ensure marketplace content quality and fairness.

#### Acceptance Criteria

1. THE Admin_Panel SHALL display a moderation queue of newly submitted reviews pending approval, flagged reviews, and reported reviews.
2. WHEN an Admin_User reviews a moderation item, THE Admin_Panel SHALL display the full review text, rating score, client identity, vendor identity, and associated booking details.
3. THE Admin_Panel SHALL allow the Admin_User to approve, reject, or request modification of a submitted review with a mandatory reason for rejection.
4. WHEN a review is rejected, THE Notification_System SHALL notify the client with the rejection reason.
5. THE Admin_Panel SHALL support automated flagging of reviews containing prohibited content patterns.

### Requirement 16: Content Management

**User Story:** As an Admin_User, I want to manage platform content including banners, announcements, and featured vendors, so that I can control the client and vendor app experience.

#### Acceptance Criteria

1. THE Content_Manager SHALL allow the Admin_User to create, edit, schedule, and remove promotional banners with image, title, action link, target audience (vendors, clients, or both), and display period.
2. THE Content_Manager SHALL allow the Admin_User to manage a featured vendors list with configurable display order and duration.
3. WHEN a banner's display period expires, THE Content_Manager SHALL automatically remove the banner from active display.
4. THE Content_Manager SHALL allow the Admin_User to create in-app announcements with rich text content, priority level, and target audience.
5. THE Content_Manager SHALL display a content calendar showing all scheduled banners and announcements with their active periods.
