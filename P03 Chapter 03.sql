-- Romika Chaudhary --
-- C0921918 --
-- Chapter 3 --
-- Jan 26, 2024 --

-- Q5
DECLARE
v_loan_amt NUMBER(7) := :ENTER_LOAN_AMOUNT;
v_loan_payment NUMBER(7) := :ENTER_LOAN_PAYMENT;
v_equal_payment NUMBER(7);
v_payNum NUMBER(2);
BEGIN
    v_payNum := v_loan_amt / v_loan_payment;
    DBMS_OUTPUT.PUT_LINE('Loan Amount: ' || TO_CHAR(v_loan_amt, 'FM$9,999.00'));
    DBMS_OUTPUT.PUT_LINE('Loan Payment: ' || TO_CHAR(v_loan_payment, 'FM$999.00'));
    DBMS_OUTPUT.PUT_LINE('Equal Payments: ' || v_payNum);
    DBMS_OUTPUT.NEW_LINE();
    DBMS_OUTPUT.PUT_LINE('Payment#' || LPAD('Balance', 9));
    DBMS_OUTPUT.PUT_LINE('--------  --------');
    FOR i IN 1 .. v_payNum LOOP
        v_loan_amt := v_loan_amt - v_loan_payment;
    DBMS_OUTPUT.PUT_LINE(RPAD(i, 9) || ' ' || TO_CHAR(v_loan_amt, 'FM9,999.00'));
END LOOP;
    DBMS_OUTPUT.NEW_LINE();
    DBMS_OUTPUT.PUT_LINE('Outstanding balance: ' || TO_CHAR(v_loan_amt, 'FM$9,999.00'));
END;



-- Q6
DECLARE
    INDIVIDUAL_MATCH_PERCENT CONSTANT NUMBER := 0.5;
    BUSINESS_MATCH_PERCENT CONSTANT NUMBER := 1;
    GRANT_MATCH_PERCENT CONSTANT NUMBER := 0.75;
    ROUND_UP_FACTOR CONSTANT NUMBER := 1;

    v_donor_id gl_donors.DONOR_ID%TYPE;
    v_donor gl_donors%ROWTYPE;
    v_total_pledge_amount NUMBER;
    v_match_amount NUMBER;

BEGIN
    v_donor_id := :ENTER_DONOR_ID; 

    SELECT * INTO v_donor
    FROM gl_donors
    WHERE DONOR_ID = v_donor_id;

    v_total_pledge_amount := v_donor.MONTHLY_PLEDGE_AMOUNT * v_donor.PLEDGE_MONTHS;

    v_match_amount := 
    CASE v_donor.DONOR_TYPE
        WHEN 'I' THEN
            CASE
                WHEN v_total_pledge_amount < 100 THEN 0
                WHEN v_total_pledge_amount >= 100 AND v_total_pledge_amount <= 249 THEN CEIL(v_total_pledge_amount * INDIVIDUAL_MATCH_PERCENT / ROUND_UP_FACTOR) * ROUND_UP_FACTOR
                WHEN v_total_pledge_amount >= 250 AND v_total_pledge_amount <= 499 THEN CEIL(v_total_pledge_amount * 0.3 / ROUND_UP_FACTOR) * ROUND_UP_FACTOR
                WHEN v_total_pledge_amount >= 500 THEN CEIL(v_total_pledge_amount * 0.2 / ROUND_UP_FACTOR) * ROUND_UP_FACTOR
                ELSE 0
            END
        WHEN 'B' THEN
            CASE
                WHEN v_total_pledge_amount < 100 THEN 0
                WHEN v_total_pledge_amount >= 100 AND v_total_pledge_amount <= 499 THEN CEIL(v_total_pledge_amount * BUSINESS_MATCH_PERCENT / ROUND_UP_FACTOR) * ROUND_UP_FACTOR
                WHEN v_total_pledge_amount >= 500 AND v_total_pledge_amount <= 999 THEN CEIL(v_total_pledge_amount * 0.1 / ROUND_UP_FACTOR) * ROUND_UP_FACTOR
                WHEN v_total_pledge_amount >= 1000 THEN CEIL(v_total_pledge_amount * 0.05 / ROUND_UP_FACTOR) * ROUND_UP_FACTOR
                ELSE 0
            END
        WHEN 'G' THEN
            CASE
                WHEN v_total_pledge_amount < 100 THEN 0
                WHEN v_total_pledge_amount >= 100 THEN CEIL(v_total_pledge_amount * GRANT_MATCH_PERCENT / ROUND_UP_FACTOR) * ROUND_UP_FACTOR
                ELSE 0
            END
        ELSE
            0 
    END;
    DBMS_OUTPUT.PUT_LINE('Donor pledge for ' || v_donor.DONOR_NAME);

    IF v_donor.DONOR_TYPE = 'I' THEN
        DBMS_OUTPUT.PUT_LINE('Donor type: Individual');
    ELSIF v_donor.DONOR_TYPE = 'B' THEN
        DBMS_OUTPUT.PUT_LINE('Donor type: Business organization');
    ELSIF v_donor.DONOR_TYPE = 'G' THEN
        DBMS_OUTPUT.PUT_LINE('Donor type: Grant funds');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Amount pledged: ' || TO_CHAR(v_total_pledge_amount, 'FM$999.00'));
    DBMS_OUTPUT.PUT_LINE('Match amount: ' || TO_CHAR(v_match_amount, 'FM$990.00'));
END;



--8
DECLARE
    loan_rec gl_loans % ROWTYPE;
    v_loan_id gl_loans.loan_id% TYPE := :Enter_loan_id;
    v_interest_discount gl_loans.annual_interest_rate%TYPE;
    v_new_annual_interest_rate gl_loans.annual_interest_rate%TYPE;
    v_balance gl_loans.loan_amount%TYPE := 0;
    v_last_payment gl_loans.loan_amount%TYPE := 0;
    v_monthly_interest gl_loans.loan_amount%TYPE := 0;
    v_payment_month NUMBER(3) := 0;
    v_years NUMBER(3) :=0;
    v_months NUMBER(2) :=0;

BEGIN
    SELECT * INTO loan_rec
    FROM gl_loans
    WHERE loan_id = v_loan_id;

    v_interest_discount :=
        CASE
            WHEN loan_rec.credit_score <= 679 THEN 0.00
            WHEN loan_rec.credit_score <= 669 THEN 0.25
            WHEN loan_rec.credit_score <= 739 THEN 0.50
            WHEN loan_rec.credit_score <= 799 THEN 0.75
            WHEN loan_rec.credit_score <= 850 THEN 1.00
        END;
        v_new_annual_interest_rate := loan_rec.annual_interest_rate - v_interest_discount;
   
    DBMS_OUTPUT.PUT_LINE('Payment Schedule');
    DBMS_OUTPUT.PUT_LINE('-----------------');
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('Name: '    || loan_rec.first_name || ' ' || loan_rec.last_name);
    DBMS_OUTPUT.PUT_LINE('Loan Amount: '  || TO_CHAR(loan_rec.loan_amount, 'FM$9,999,999.00'));
    DBMS_OUTPUT.PUT_LINE('Annual Interest Rate:  '|| loan_rec.annual_interest_rate || '%');
    DBMS_OUTPUT.PUT_LINE('Credit Score:  ' || loan_rec.credit_score || 'Interest Discount: '|| TO_CHAR(v_interest_discount, 'FM0.99') ||'%');
    DBMS_OUTPUT.PUT_LINE('New Annual Interest Rate: ' || v_new_annual_interest_rate || '%');
    DBMS_OUTPUT.PUT_LINE('Monthly Payment: ' || TO_CHAR(loan_rec.monthly_payment,'FM$99,999.00'));
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE(LPAD('Month', 15) || LPAD('Interest', 16) || LPAD('Payment', 16) || LPAD('Balance', 16));

    v_balance := loan_rec.loan_amount;
    WHILE v_balance >= loan_rec.monthly_payment LOOP
        v_payment_month := v_payment_month + 1;
        v_monthly_interest := v_balance * (v_new_annual_interest_rate /12/100);
        v_balance := v_balance + v_monthly_interest - loan_rec.monthly_payment;
        DBMS_OUTPUT.PUT_LINE(LPAD(v_payment_month,15) || LPAD(TO_CHAR(v_monthly_interest,'FM99,999.00'), 15) || LPAD(TO_CHAR(loan_rec.monthly_payment,'FM9,999.00'), 15) || LPAD(TO_CHAR(v_balance,'FM$9,999,999.00'), 15));
    END LOOP;

    v_payment_month := v_payment_month + 1;
    v_monthly_interest := v_balance * (v_new_annual_interest_rate / 12/ 100);
    v_last_payment := v_balance + v_monthly_interest;
    v_balance := 0;
    DBMS_OUTPUT.PUT_LINE(LPAD(v_payment_month, 15)|| LPAD(TO_CHAR(v_monthly_interest,'FM99,999.00'), 15)|| LPAD(TO_CHAR(v_last_payment,'FM99,999.00'), 15)||LPAD(TO_CHAR(v_balance,'FM$9,990.00'),15));

    v_years := FLOOR (v_payment_month / 12);
    v_months := MOD(v_payment_month, 12);
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('It Takes ' || v_years || ' years old ' || v_months || ' months to pay this loan');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('* The Following undetermined error occured. COntact software support.***');
        DBMS_OUTPUT.PUT_LINE('* Error Code: ' || SQLCODE || ' ' || SQLERRM || '**');
END;