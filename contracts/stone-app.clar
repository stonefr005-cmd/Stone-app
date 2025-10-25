;; title: stone-app
;; version: 0.1.0
;; summary: A simple stone app
;; description: This is a simple stone app
;; stone-app
;; Short & error-free Clarity contract for a decentralized voting app

(define-data-var poll-counter uint u0)

(define-map polls
    { id: uint }
    {
        creator: principal,
        question: (string-ascii 50),
        yes-votes: uint,
        no-votes: uint,
        status: (string-ascii 10),
    }
)

;; Create a new poll
(define-public (create-poll (question (string-ascii 50)))
    (let ((id (var-get poll-counter)))
        (map-set polls { id: id } {
            creator: tx-sender,
            question: question,
            yes-votes: u0,
            no-votes: u0,
            status: "open",
        })
        (var-set poll-counter (+ id u1))
        (ok id)
    )
)

;; Vote on a poll
(define-public (vote
        (id uint)
        (vote-yes bool)
    )
    (match (map-get? polls { id: id })
        poll
        (if (is-eq (get status poll) "open")
            (begin
                (map-set polls { id: id } {
                    creator: (get creator poll),
                    question: (get question poll),
                    yes-votes: (if vote-yes
                        (+ (get yes-votes poll) u1)
                        (get yes-votes poll)
                    ),
                    no-votes: (if vote-yes
                        (get no-votes poll)
                        (+ (get no-votes poll) u1)
                    ),
                    status: (get status poll),
                })
                (ok "Voted")
            )
            (err u1)
        )
        ;; poll not open
        (err u2) ;; poll not found
    )
)

;; Close a poll
(define-public (close-poll (id uint))
    (match (map-get? polls { id: id })
        poll
        (if (and (is-eq (get status poll) "open") (is-eq tx-sender (get creator poll)))
            (begin
                (map-set polls { id: id } {
                    creator: (get creator poll),
                    question: (get question poll),
                    yes-votes: (get yes-votes poll),
                    no-votes: (get no-votes poll),
                    status: "closed",
                })
                (ok "Poll closed")
            )
            (err u3)
        )
        ;; not open or not creator
        (err u4) ;; poll not found
    )
)