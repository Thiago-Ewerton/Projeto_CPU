stateDiagram-v2
    [*] --> WAIT_INIT
    
    WAIT_INIT --> PREPARE: init_done=1
    
    IDLE --> PREPARE: start=1
    
    PREPARE --> PULSE_E: sempre
    
    PULSE_E --> WAIT: delay_pulse = 0
    
    WAIT --> DONE: msg_index = 34
    WAIT --> PREPARE: msg_index < 34
    
    DONE --> IDLE: sempre
    
    note right of PULSE_E
        Enable = 1 por ~1us
        (50 ciclos de clock)
    end note
    
    note right of WAIT
        Espera ~40us
        (2000 ciclos)
    end note
    
    style WAIT_INIT fill:#90EE90
    style PREPARE fill:#87CEEB
    style PULSE_E fill:#87CEEB
    style WAIT fill:#87CEEB
    style DONE fill:#FFD700
    style IDLE fill:#FFB6C1
