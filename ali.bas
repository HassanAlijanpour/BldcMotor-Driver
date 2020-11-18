'________________________________________________________________________'
'                                                                        '
'Description:    Brushless Motor Controller for ATmega48/88/168          '
'Author     :    alireza roozitalab                                      '
'date       :    2012/1/13                                               '
'version    :    1.0                                                     '
'________________________________________________________________________'
'                                                                        '

$regfile = "m88def.dat"
$crystal = 8000000
Motor_adr Alias &H70
Dim Start_pwm As Byte
Start_pwm = 50
Stop_pwm Alias 255
Dim A As Byte
Dim I As Byte
Dim Rotor_run As Byte
Dim Rotor_state As Byte
'timer & pwm part_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- _-_-_-_-_-_-_-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- '
'compare registers________________________________'
Comp_multi Alias Adcsrb.6                                   'in ADCSRB(Acme)  for use ADC multiplexer for AIN1(pin ain1 disable) page242 of datashet
Comp_digital Alias Didr1.0                                  'in DIDR1(AIN0D)   for digital input disable in ain0 and analog signal enabale in ain0  page243 of datashet
Comp_enable Alias Acsr.3                                    'in ACSR(Acie)    for enable INTERRUPTS of comparator page242 of datashet
'pwma registers___________________________________'
Pwma_cmob_mode Alias Tccr0a.5                               'in TCCR0A(Com0b1)  for enabe pwm oc0b and the mode of pwm (UP/DOWN counter)(depend of WGM00 & WGM01) page102 of datashet
Pwma_wg1_mode Alias Tccr0a .1                               'in TCCR0A(Wgm01)  for appoint the pwm mode   page103 of datashet
Pwma_wg0_mode Alias Tccr0a.0                                'in TCCR0A(Wgm00)  for appoint the pwm mode   page103 of datashet
Pwma_clock Alias Tccr0b.0                                   'in TCCR0B(Cs00 )  for appoint timer/counter0 clock source (prescale of timer0 ,NO prescaler)page104 of datashet
'pwmb registers___________________________________'
Pwmb_cmoa_mode Alias Tccr2a.7                               'in TCCR2A(Com2a1)  for enabe pwm oc2A and the mode of pwm (UP/DOWN counter)(depend of WGM20 & WGM21) page153 of datashet
Pwmb_cmob_mode Alias Tccr2a.5                               'in TCCR2A(Com2b1)  for enabe pwm oc2B and the mode of pwm (UP/DOWN counter)(depend of WGM20 & WGM21) page153 of datashet
Pwmb_wg1_mode Alias Tccr2a.1                                'in TCCR2A (Wgm21)  for appoint the pwm mode   page153 of datashet
Pwmb_wg0_mode Alias Tccr2a.0                                'in TCCR2A(Wgm20)  for appoint the pwm mode   page153 of datashet
Pwmb_clock Alias Tccr2b.0                                   'in TCCR2B(Cs20)  for appoint timer/counter2 clock source (prescale of timer2 ,NO prescaler)page104 of datashet


'phase part_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- _-_-_-_-_-_-_-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- '
'phase1(u)_________________________________________'
Uh_ddr Alias Ddrb.3                                         'uh is conect to portb.3 and for pwm the pin state is neccecery and should be output page 153 datashet
Uh_prt Alias Portb.3
Uh_pwm_ctrl Alias Tccr2a
Uh_pwm_mod Alias Tccr2a.7                                   'Com2a1
Uh_pwm_set Alias Ocr2a
Ul_ddr Alias Ddrb.1                                         'ul is conect to portb.1
Ul_prt Alias Portb.1
'phase2(v)_________________________________________'
Vh_ddr Alias Ddrd.5                                         'uh is conect to portb.3 and for pwm the pin state is neccecery and should be output page 153 datashet
Vh_prt Alias Portd.5
Vh_pwm_ctrl Alias Tccr0a
Vh_pwm_mod Alias Tccr0a.5                                   'Com0b1
Vh_pwm_set Alias Ocr0b
Vl_ddr Alias Ddrb.2                                         'ul is conect to portb.2
Vl_prt Alias Portb.2
'phase3(w)_________________________________________'
Wh_ddr Alias Ddrd.3                                         'wh is conect to portd.5 and for pwm the pin state is neccecery and should be output page 153 datashet
Wh_prt Alias Portd.3
Wh_pwm_ctrl Alias Tccr2a
Wh_pwm_mod Alias Tccr2a.5                                   'Com2b1
Wh_pwm_set Alias Ocr2b                                      'the amount of the register compare with timer value and this compare use for pwm
Wl_ddr Alias Ddrc.3                                         'wl is conect to portb.2
Wl_prt Alias Portc.3
'IO part_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- _-_-_-_-_-_-_-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- _-_-_-_-_-_- '

'led(output)_______________________________________'
Led_prt Alias Portb.0
Led_ddr Alias Ddrb.0
'Start/Stop Key (input)____________________________'
Spkey_prt Alias Portd.7
Spkey_ddr Alias Ddrd.7
Spkey_pin Alias Pind.7
'up Key (input)____________________________________'
Upkey_prt Alias Portd.2
Upkey_ddr Alias Ddrd.2
Upkey_pin Alias Pind.2
'Down Key (input)__________________________________'
Dnkey_prt Alias Portd.4
Dnkey_ddr Alias Ddrd.4
Dnkey_pin Alias Pind.4



Gosub Hw_init
Gosub Blmc_init
Config Timer1 = Timer , Prescale = 8
Config Aci = On , Compare = Off
Enable Interrupts
Enable Timer1
Enable Ovf1
Enable Aci
On Ovf1 Timer1_ovf_vect
On Aci Analog_comp_vect
Start Timer1
Uh_pwm_set = Start_pwm
Vh_pwm_set = Start_pwm
Wh_pwm_set = Start_pwm

Do
If Pind.4 = 0 And Start_pwm < 255 Then Start_pwm = Start_pwm + 25
If Pind.2 = 0 And Start_pwm > 0 Then Start_pwm = Start_pwm - 25
Uh_pwm_set = Start_pwm
Vh_pwm_set = Start_pwm
Wh_pwm_set = Start_pwm


Waitms 500


Loop






End



Keycheck:
Return




Blmc_init:
Gosub Blmc_hw_ini
Gosub Pwm_init
Gosub Phase_all_off
Gosub Comp_init
Return





Hw_init:
Set Led_ddr
Reset Led_prt
Reset Spkey_ddr
Set Spkey_prt
Reset Upkey_ddr
Set Upkey_prt
Reset Dnkey_ddr
Set Dnkey_prt

Return







Phase_all_off:
Reset Uh_pwm_mod
Reset Vh_pwm_mod
Reset Wh_pwm_mod
Set Ul_prt
Set Vl_prt
Set Wl_prt
Return

Blmc_hw_ini:
Set Uh_ddr
Set Ul_ddr
Set Vh_ddr
Set Vl_ddr
Set Wh_ddr
Set Wl_ddr
Return


Pwm_init:
Set Pwma_cmob_mode                                          '
Set Pwma_wg1_mode                                           '
Set Pwma_wg0_mode                                           '
Set Pwma_clock                                              '
Set Pwmb_cmoa_mode
Set Pwmb_cmob_mode
Set Pwmb_wg1_mode
Set Pwmb_wg0_mode
Set Pwmb_clock
Return




Comp_init:
Set Comp_multi
Set Comp_digital
Set Comp_enable
Return

Timer1_ovf_vect:

Uh_pwm_set = Start_pwm
Vh_pwm_set = Start_pwm
Wh_pwm_set = Start_pwm
I = 1
Gosub Next_commutate_state
Rotor_run = 0
Return

Analog_comp_vect:
If Rotor_run = 200 Then
I = 0
Gosub Next_commutate_state
End If
Rotor_run = Rotor_run + 1
If Rotor_run > 200 Then Rotor_run = 200
Return



Next_commutate_state:
Select Case Rotor_state

Case 0:
If Acsr.5 = 0 Or I = 1 Then
Reset Wh_pwm_mod
Set Uh_pwm_mod
Admux = 2
Rotor_state = 1
Timer1 = 1
End If

Case 1:
If Acsr.5 = 1 Or I = 1 Then
Set Vl_prt
Reset Wl_prt
Admux = 1
Rotor_state = 2
Timer1 = 1
End If

Case 2:
If Acsr.5 = 0 Or I = 1 Then
Reset Uh_pwm_mod
Set Vh_pwm_mod
Admux = 0
Rotor_state = 3
Timer1 = 1
End If

Case 3:
If Acsr.5 = 1 Or I = 1 Then
Set Wl_prt
Reset Ul_prt
Admux = 2
Rotor_state = 4
Timer1 = 1
End If

Case 4:
If Acsr.5 = 0 Or I = 1 Then
Reset Vh_pwm_mod
Set Wh_pwm_mod
Admux = 1
Rotor_state = 5
Timer1 = 1
End If

Case 5:
If Acsr.5 = 1 Or I = 1 Then
Set Ul_prt
Reset Vl_prt
Admux = 0
Rotor_state = 0
Timer1 = 1
End If

End Select

Return