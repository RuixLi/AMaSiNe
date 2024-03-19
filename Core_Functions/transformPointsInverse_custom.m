function varargout = transformPointsInverse_custom(self,varargin)
%transformPointsInverse Apply inverse geometric transformation
%
%   [u,v] = transformPointsInverse(tform,x,y)
%   applies the inverse transformation of tform to the input 2-D
%   point arrays x,y and outputs the point arrays u,v. The
%   input point arrays x and y must be of the same size.
%
%   U = transformPointsInverse(tform,X)
%   applies the inverse transformation of tform to the input
%   Nx2 point matrix X and outputs the Nx2 point matrix U.
%   transformPointsFoward maps the point X(k,:) to the point
%   U(k,:).
b=tic;
if numel(varargin) > 1
    x = varargin{1};
    y = varargin{2};
    
    validateattributes(x,{'single','double'},{'real','nonsparse'},...
        'transformPointsInverse','X');
    
    validateattributes(y,{'single','double'},{'real','nonsparse'},...
        'transformPointsInverse','Y');
    
    if ~isequal(size(x),size(y))
        error(message('images:geotrans:transformPointsSizeMismatch','transformPointsInverse','X','Y'));
    end
    
    inputPointDims = size(x);
    
    x = reshape(x,numel(x),1);
    y = reshape(y,numel(y),1);
    X = [x,y];
    X = self.normTransformXY.transformPointsInverse(X); % normalize
    U = images.geotrans.internal.inv_piecewiselinear(self.State,double(X));
    U = self.normTransformUV.transformPointsForward(U); % denormalize
    
    % If class was constructed from single control points or if
    % points passed to transformPointsInverse are single,
    % return single to emulate MATLAB Math casting rules.
    if isa(X,'single') || strcmp(self.NumericPrecision,'single')
        U = single(U);
    end
    varargout{1} = reshape(U(:,1),inputPointDims);
    varargout{2} = reshape(U(:,2), inputPointDims);
    
else
    X = varargin{1};
    
    validateattributes(X,{'single','double','gpuArray'},{'real','nonsparse','2d'},...
        'transformPointsInverse','X');
    
    if ~isequal(size(X,2),2)
        error(message('images:geotrans:transformPointsPackedMatrixInvalidSize',...
            'transformPointsInverse','X'));
    end
    
    X = self.normTransformXY.transformPointsInverse(X); % normalize
    U = images.geotrans.internal.inv_piecewiselinear(self.State,double(X));
    U = self.normTransformUV.transformPointsForward(U); % denormalize
    
    % If class was constructed from single control points or if
    % points passed to transformPointsInverse are single,
    % return single to emulate MATLAB Math casting rules.
    if isa(X,'single') || strcmp(self.NumericPrecision,'single')
        U = single(U);
    end
    varargout{1} = U;
end

ccc=toc(b)
end