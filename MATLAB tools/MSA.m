function m = MSA(A, ref)

%This function is used to compute the Minimum Specific Acceleration (MSA). This is the absolute value of the norm of the acceleration minus 1 g, i.e., the amount that the acceleration differs from the gravity value. This is always equal to or less than the actual specific acceleration if A is correctly calibrated.
% Possible input combinations: msa(A) if A is a list, msa(A,ref) if A is a matrix.
%INPUT 
%       A=An nx3 acceleration matrix with columns [ax ay az], or a tag sensor data list containing acceleration data. Acceleration can be in any consistent unit, e.g., g or m/s^2. A can be in any frame as the MSA is rotation independent.
%       ref=The gravitational field strength in the same units as A. This is not needed if A is a sensor structure. If A is a matrix, the default value is 9.81 which assumes that A is in m/s^2. Use ref = 1 if the unit of A is g.
%OUTPUT
%       m= column vector of MSA with the same number of rows as A, or a tag sensor data list (output matches input). m has the same units as A.
   
% input checks-----------------------------------------------------------
    if nargin < 2 || isempty(ref)
        ref = 9.81;
    end
    if isstruct(A)
        if isfield(A, 'meta_conv') && ~isempty(A.meta_conv)
            ref = ref * A.meta_conv;
        end
        if isfield(A, 'data')
            A0 = A;
            A = A.data;
        else
            % try to coerce data frame to matrix
            A = table2array(A);
        end
    end

    % catch the case of a single acceleration vector
    if min([size(A, 1), size(A, 2)]) == 1
        error('A must be an acceleration matrix');
    end
    m = abs(sqrt(sum(A.^2, 2)) - ref);
    if exist('A0', 'var')
        M = A0;
        M.data = m;
        M.creation_date = datetime('now');
        M.type = 'msa';
        M.full_name = 'minimum specific acceleration';
        M.description = M.full_name;
        M.column_name = 'msa';
        m = M;
    end
end

% minimum specific acceleration 
% norm of the acceleration vector = sqrt(ax2 + ay2 + az2)
% minimum specific acceleration is absolute value of sqrt(ax2 + ay2 +az2)-1
%Ax=Aw(:,1).^2;
%Ay=Aw(:,2).^2;
%Az=Aw(:,3).^2;
%normA=sqrt(Ax +  Ay + Az );
%msa_g=abs(normA-1); % this is in units of g which is 9.81m/s2... so can i multiply these values by 9.81 to get the msa in m/s2 units?
%msa=msa_g*9.81;