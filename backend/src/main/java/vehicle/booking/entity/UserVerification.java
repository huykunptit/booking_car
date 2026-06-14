package vehicle.booking.entity;

import jakarta.persistence.*;
import lombok.*;
import vehicle.booking.entity.enums.VerificationStatus;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_verifications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserVerification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    // CCCD / CMND fields
    @Column(name = "cccd_number")
    private String cccdNumber;

    @Column(name = "full_name")
    private String fullName;

    @Column(name = "birth_day")
    private String birthDay;

    @Column(name = "address", columnDefinition = "TEXT")
    private String address;

    @Column(name = "issue_date")
    private String issueDate;

    @Column(name = "expiry")
    private String expiry;

    @Column(name = "cccd_verified")
    private Boolean cccdVerified = false;

    @Column(name = "cccd_spoofed")
    private Boolean cccdSpoofed = false;

    // Driver license fields
    @Column(name = "license_number")
    private String licenseNumber;

    @Column(name = "license_name")
    private String licenseName;

    @Column(name = "license_expiry")
    private String licenseExpiry;

    @Column(name = "license_class")
    private String licenseClass;

    @Column(name = "license_verified")
    private Boolean licenseVerified = false;

    @Column(name = "license_spoofed")
    private Boolean licenseSpoofed = false;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private VerificationStatus status = VerificationStatus.UNVERIFIED;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
