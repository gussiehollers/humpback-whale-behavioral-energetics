function e=ODBA(A, sampling_rate, fh, method, n)
%ODBA 
%modified from stacy deruiter's code in R

%This function is used to compute the 'Overall Dynamic Body Acceleration' sensu Wilson et al. 2006. ODBA is the norm of the high-pass-filtered acceleration. Several methods for computing ODBA are in use which differ by which norm and which filter are used. 
% In the Wilson paper, the 1-norm and a rectangular window (moving average) filter are used. The moving average is subtracted from the input accelerations to implement a high-pass filter. 
% The default method and VeDBA method are rotation independent and so give the same result irrespective of the frame of A. The 1-norm method has a more complex dependency on frame.
%The 2-norm may be preferable if the tag orientation is unknown or may change and this is termed VeDBA. A tapered symmetric FIR  filter gives more efficient high-pass filtering compared to the rectangular window method and avoids lobes in the response.

%INPUT
%       A= tag sensor data list containing tri-axial acceleration data or an nx3 acceleration matrix with columns [ax ay az]. Acceleration can be in any consistent unit, e.g., g or m/s^2. A can be in any frame but the result depends on the method used to compute ODBA. 
%       sampling_rate= The sampling rate in Hz of the acceleration signals. Required for 'fir' method if A is not a tag sensor data list.
%       fh= The high-pass filter cut-off frequency in Hz. This should be chosen to be about half of the stroking rate for the animal (e.g., using dsf.R). Required for the default 'fir' method.
%       method= A character containing either 'wilson' or 'vedba' or 'fir'. This determines the method by which the ODBA is calculated. The default method is 'fir'.
%       n=The rectangular window (moving average) length in samples. This is only needed if using the classic ODBA and VeDBA forms (methods 'wilson' and 'vedba').
% 
% OUTPUT
%       e=column vector of ODBA with the same number of rows as A. e has the same units as A.
%       note If applying the default (FIR filtering) method to calculate odba, use the inputs A, sampling_rate, and fh. When applying the 'vedba' or 'wilson' method, use the inputs A, n, and method.


     if isstruct(A)
        sampling_rate = A.sampling_rate;
        A = A.data;
    end

    if strcmp(method, 'fir')
        if isempty(sampling_rate) || isempty(fh)
            error('sampling_rate (unless A is a tag sensor data list) and fh are required inputs to compute odba by the FIR method');
        end
        n = 5 * round(sampling_rate / fh);
        Ah = fir_nodelay(A, n, (fh / (sampling_rate / 2)), 'high');
        e = sqrt(sum(abs(Ah).^2, 2));
    else
        if strcmp(method, 'vedba') || strcmp(method, 'wilson')
            if isempty(n)
                error('n is a required input to compute odba by the vedba or wilson methods');
            end
            n = 2 * floor(n / 2) + 1; % make sure n is odd
            nz = floor(n / 2);
            h = [
                zeros(nz, 1);
                ones(1, 1);
                zeros(nz, 1)
            ] - ones(n, 1) / n;

            % filter A with h
            Ah = filter(h, 1, [
                zeros(nz, size(A, 2));
                A;
                zeros(nz, size(A, 2))
            ]);
            Ah = Ah(n - 1 + (1:size(A, 1)), :);
            if strcmp(method, 'vedba')
                e = sqrt(sum(abs(Ah).^2, 2)); % use 2-norm
            else
                if strcmp(method, 'wilson')
                    e = sum(abs(Ah), 2); % use 1-norm
                end
            end
        end
    end
end