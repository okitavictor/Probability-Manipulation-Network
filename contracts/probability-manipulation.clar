;; Probability Manipulation Request Contract

(define-data-var request-counter uint u0)

(define-map probability-requests uint {
    requester: principal,
    target-state: (string-utf8 500),
    desired-outcome: (string-utf8 500),
    quantum-signature: (buff 32),
    status: (string-ascii 20),
    created-at: uint,
    resolved-at: uint
})

(define-public (create-request (target-state (string-utf8 500)) (desired-outcome (string-utf8 500)) (quantum-signature (buff 32)))
    (let
        ((new-id (+ (var-get request-counter) u1)))
        (map-set probability-requests new-id {
            requester: tx-sender,
            target-state: target-state,
            desired-outcome: desired-outcome,
            quantum-signature: quantum-signature,
            status: "pending",
            created-at: block-height,
            resolved-at: u0
        })
        (var-set request-counter new-id)
        (ok new-id)
    )
)

(define-public (update-request-status (request-id uint) (new-status (string-ascii 20)))
    (let
        ((request (unwrap! (map-get? probability-requests request-id) (err u404))))
        (asserts! (is-eq tx-sender (get requester request)) (err u403))
        (ok (map-set probability-requests request-id
            (merge request {
                status: new-status,
                resolved-at: (if (is-eq new-status "resolved") block-height (get resolved-at request))
            })))
    )
)

(define-read-only (get-request (request-id uint))
    (map-get? probability-requests request-id)
)

(define-read-only (get-request-count)
    (var-get request-counter)
)

