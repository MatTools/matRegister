classdef CubicBSplineTransform3D < ParametricTransform
%CUBICBSPLINETRANSFORM3D Cubic Spline Transform model in 3D
%
%   output = CubicBSplineTransform3D(input)
%
%   Example
%   CubicBSplineTransform3D
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-02-16,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

%% Properties
properties
    % Number of vertices of the grid in each direction
    gridSize;
    
    % Coordinates of the first vertex of the grid
    gridOrigin;
    
    % Spacing between the vertices
    gridSpacing;
end 

%% Constructor
methods
    function this = CubicBSplineTransform3D(varargin)
        % Ajouter le code du constructeur ici
        if nargin==1
            var = varargin{1};
            if isscalar(var)
                nd = var;
                this.gridSize       = ones(1, nd);
                this.gridSpacing    = ones(1, nd);
                this.gridOrigin     = zeros(1, nd);
                initializeParameters();
            end
            
        elseif nargin==3
            this.gridSize       = varargin{1};
            this.gridSpacing    = varargin{2};
            this.gridOrigin     = varargin{3};
            initializeParameters();
        end

        function initializeParameters()
            dim = this.gridSize();
            np  = prod(dim) * length(dim);
            this.params = zeros(1, np);
        end
    end % constructor 

end % construction function

%% General methods
methods
    function dim = getDimension(this) %#ok<MANU>
        dim = 3;
    end

    function [point2, isInside] = transformPoint(this, point)
        % Compute coordinates of transformed point
        
        % compute centered coords.
        x = point(:, 1);
        y = point(:, 2);
        z = point(:, 3);
        
        % compute position wrt to the grid vertices
        xg = (x - this.gridOrigin(1)) / this.gridSpacing(1) + 1;
        yg = (y - this.gridOrigin(2)) / this.gridSpacing(2) + 1;
        zg = (z - this.gridOrigin(3)) / this.gridSpacing(3) + 1;
        
        % compute indices of points located within interpolation area
        isInsideX   = xg >= 2 & xg < this.gridSize(1)-1;
        isInsideY   = yg >= 2 & yg < this.gridSize(2)-1;
        isInsideZ   = zg >= 2 & zg < this.gridSize(3)-1;
        isInside    = isInsideX & isInsideY & isInsideZ;

        % select valid points
        xg = xg(isInside);
        yg = yg(isInside);
        zg = zg(isInside);
        
        % number of valid points
        nValid = length(xg);

        % compute indices in linear indexing
        dimX    = this.gridSize(1);
        dimXY   = this.gridSize(1) * this.gridSize(2);
        dimXYZ  = prod(this.gridSize);

        % coordinates within the unit tile
        xu = xg - floor(xg);
        yu = yg - floor(yg);
        zu = zg - floor(zg);
       
        % initialize zeros translation vector
        dx = zeros(length(xg), 1);
        dy = zeros(length(xg), 1);
        dz = zeros(length(xg), 1);
        
        baseFuns = {...
            @BSplines.beta3_0, ...
            @BSplines.beta3_1, ...
            @BSplines.beta3_2, ...
            @BSplines.beta3_3};
        
        % pre-compute values of b-splines functions
        evals_i = zeros(nValid, 4);
        evals_j = zeros(nValid, 4);
        evals_k = zeros(nValid, 4);
        for i = 1:4
            fun = baseFuns{i};
            evals_i(:,i) = fun(xu);
            evals_j(:,i) = fun(yu);
            evals_k(:,i) = fun(zu);
        end
        
        
        % iteration on each tile of the grid
        for i = -1:2
            xv = floor(xg) + i;
            
            for j = -1:2
                yv = floor(yg) + j;
                
                % pre-compute weight for all vertices in same plane
                evals_ij = evals_i(:, i+2) .* evals_j(:, j+2);
                
                for k = -1:2
                    zv = floor(zg) + k;
                
                    b = evals_ij .* evals_k(:, k+2);

                    % linear index of translation components
                    indX = (zv - 1) * dimXY + (yv - 1) * dimX + xv;
                    indY = indX + dimXYZ;
                    indZ = indX + 2 * dimXYZ;

                    % update total translation component
                    dx = dx + b .* this.params(indX)';
                    dy = dy + b .* this.params(indY)';
                    dz = dz + b .* this.params(indZ)';

                end                
            end
        end
        
        % update coordinates of transformed point
        point2 = point;
        point2(isInside, 1) = point(isInside, 1) + dx;
        point2(isInside, 2) = point(isInside, 2) + dy;
        point2(isInside, 3) = point(isInside, 3) + dy;
                
    end
    
    function ux = getUx(this, x, y, z)
        ind = sub2ind([this.gridSize 3], x, y, z, 1);
        ux = this.params(ind);
    end
    
    function setUx(this, x, y, z, ux)
        ind = sub2ind([this.gridSize 3], x, y, z, 1);
        this.params(ind) = ux;
    end
    
    function uy = getUy(this, x, y, z)
        ind = sub2ind([this.gridSize 3], x, y, z, 2);
        uy = this.params(ind);
    end
    
    function setUy(this, x, y, z, uy)
        ind = sub2ind([this.gridSize 3], x, y, z, 2);
        this.params(ind) = uy;
    end
    
    function uz = getUz(this, x, y, z)
        ind = sub2ind([this.gridSize 3], x, y, z, 3);
        uz = this.params(ind);
    end
    
    function setUz(this, x, y, z, uz)
        ind = sub2ind([this.gridSize 3], x, y, z, 3);
        this.params(ind) = uz;
    end
    
    function drawGrid(this)

        % create vertex array
        v = getGridVertices(this);
        
        nv = size(v, 1);
        inds = reshape(1:nv, this.gridSize);
        
        % grid size
        dim = this.gridSize();
        
        % edges in direction x
        ne1 = (dim(2) - 1) * dim(1) * dim(3);
        e1 = [reshape(inds(:, 1:end-1, :), [ne1 1]) reshape(inds(:, 2:end, :), [ne1 1])];
        
        % edges in direction y
        ne2 = dim(2) * (dim(1) - 1) * dim(3);
        e2 = [reshape(inds(1:end-1, :, :), [ne2 1]) reshape(inds(2:end, :, :), [ne2 1])];
        
        % edges in direction z
        ne3 = dim(2) * dim(1) * (dim(3) - 1);
        e3 = [reshape(inds(:, :, 1:end-1), [ne3 1]) reshape(inds(:, :, 2:end), [ne3 1])];

        % create edge array
        e = cat(1, e1, e2, e3);

        drawGraph(v, e);
    end
    
    function vertices = getGridVertices(this)
        % get coordinates of grid vertices
        
        % base coordinates of grid vertices
        lx = (0:this.gridSize(1) - 1) * this.gridSpacing(1) + this.gridOrigin(1);
        ly = (0:this.gridSize(2) - 1) * this.gridSpacing(2) + this.gridOrigin(2);
        lz = (0:this.gridSize(3) - 1) * this.gridSpacing(3) + this.gridOrigin(3);
        
        % create base mesh
        [y, x, z] = meshgrid(ly, lx, lz);
              
        % number of vertices 
        nv = numel(x);
        
        % add grid shifts
        x = x + reshape(this.params(1:nv), this.gridSize);
        y = y + reshape(this.params(nv+(1:nv)), this.gridSize);
        z = z + reshape(this.params(2*nv+(1:nv)), this.gridSize);
        
        % create vertex array
        vertices = [x(:) y(:) z(:)];
    end
    
    function transformVector(this, varargin)
        error('MatRegister:UnimplementedMethod', ...
            'Method "%s" is not implemented for class "%s"', ...
            'transformVector', mfilename);
    end
    
    function jac = getJacobian(this, point)
        % Jacobian matrix of the given point
        %
        
        
        %% Constants
        
        % bspline basis functions and derivative functions
        baseFuns = {...
            @BSplines.beta3_0, ...
            @BSplines.beta3_1, ...
            @BSplines.beta3_2, ...
            @BSplines.beta3_3};
        
        derivFuns = {...
            @BSplines.beta3_0d, ...
            @BSplines.beta3_1d, ...
            @BSplines.beta3_2d, ...
            @BSplines.beta3_3d};

        
        %% Initializations
       
        % extract coordinates
        x = point(:, 1);
        y = point(:, 2);
        z = point(:, 3);
        
        % compute position wrt to the grid vertices
        deltaX = this.gridSpacing(1);
        deltaY = this.gridSpacing(2);
        deltaZ = this.gridSpacing(3);
        xg = (x - this.gridOrigin(1)) / deltaX + 1;
        yg = (y - this.gridOrigin(2)) / deltaY + 1;
        zg = (z - this.gridOrigin(3)) / deltaZ + 1;
        
        % compute indices of values within interpolation area
        isInsideX = xg >= 2 & xg < this.gridSize(1)-1;
        isInsideY = yg >= 2 & yg < this.gridSize(2)-1;
        isInsideZ = zg >= 2 & zg < this.gridSize(3)-1;
        isInside = isInsideX & isInsideY & isInsideZ;
        inds = isInside;

        % keep only valid positions
        xg = xg(isInside);
        yg = yg(isInside);
        zg = zg(isInside);
        
        % initialize zeros translation vector
        nValid = length(xg);

        % coordinates within the unit tile
        xu = reshape(xg - floor(xg), [1 1 nValid]);
        yu = reshape(yg - floor(yg), [1 1 nValid]);       
        zu = reshape(zg - floor(zg), [1 1 nValid]);

        % compute indices in linear indexing
        dimGrid = this.gridSize;
        dimX    = dimGrid(1);
        dimXY   = dimX * dimGrid(2);
        dimXYZ  = dimXY * dimGrid(3);
        
        % allocate memory for storing result, and initialize to identity
        % matrix
        jac = zeros(3, 3, size(point, 1));
        jac(1, 1, :) = 1;
        jac(2, 2, :) = 1;
        jac(3, 3, :) = 1;
        
        % pre-compute values of b-splines functions
        bx  = zeros(nValid, 4);
        by  = zeros(nValid, 4);
        bz  = zeros(nValid, 4);
        bxd = zeros(nValid, 4);
        byd = zeros(nValid, 4);
        bzd = zeros(nValid, 4);
        for i = 1:4
            fun = baseFuns{i};
            bx(:,i) = fun(xu);
            by(:,i) = fun(yu);
            bz(:,i) = fun(zu);
            fun = derivFuns{i};
            bxd(:,i) = fun(xu);
            byd(:,i) = fun(yu);
            bzd(:,i) = fun(zu);
        end

        %% Iteration on neighbor tiles 
        
        for i = 1:4
            % x-coordinate of neighbor vertex
            xv  = floor(xg) + i - 2;
            
            for j = 1:4
                
                % y-coordinate of neighbor vertex
                yv  = floor(yg) + j - 2;

                for k = 1:4
                    
                    % z-coordinate of neighbor vertex
                    zv  = floor(zg) + k - 2;
                    
                    % linear index of translation components
                    indX = (zv - 1) * dimXY + (yv - 1) * dimX + xv;
                    indY = indX + dimXYZ;
                    indZ = indX + 2 * dimXYZ;

                    % translation vector of the current vertex
                    dxv = reshape(this.params(indX), [1 1 length(inds)]);
                    dyv = reshape(this.params(indY), [1 1 length(inds)]);
                    dzv = reshape(this.params(indZ), [1 1 length(inds)]);
                    
                    
                    % update jacobian matrix elements
                    jac(1, 1, inds) = jac(1, 1, inds) + bxd(:,i) .* by(:,j)  .* bz(:,k)  .* dxv / deltaX;
                    jac(1, 2, inds) = jac(1, 2, inds) + bx(:,i)  .* byd(:,j) .* bz(:,k)  .* dxv / deltaY;
                    jac(1, 3, inds) = jac(1, 3, inds) + bx(:,i)  .* by(:,j)  .* bzd(:,k) .* dxv / deltaZ;
                    jac(2, 1, inds) = jac(2, 1, inds) + bxd(:,i) .* by(:,j)  .* bz(:,k)  .* dyv / deltaX;
                    jac(2, 2, inds) = jac(2, 2, inds) + bx(:,i)  .* byd(:,j) .* bz(:,k)  .* dyv / deltaY;
                    jac(2, 3, inds) = jac(2, 3, inds) + bx(:,i)  .* by(:,j)  .* bzd(:,k) .* dyv / deltaZ;
                    jac(3, 1, inds) = jac(3, 1, inds) + bxd(:,i) .* by(:,j)  .* bz(:,k)  .* dzv / deltaX;
                    jac(3, 2, inds) = jac(3, 2, inds) + bx(:,i)  .* byd(:,j) .* bz(:,k)  .* dzv / deltaY;
                    jac(3, 3, inds) = jac(3, 3, inds) + bx(:,i)  .* by(:,j)  .* bzd(:,k) .* dzv / deltaZ;
                    
                end
            end
        end

    end
    
    function jac = getParametricJacobian(this, x, varargin)
        % Compute parametric jacobian for a specific position
        % The result is a ND-by-NP array, where ND is the number of
        % dimension, and NP is the number of parameters.
        
        % extract coordinate of input point
        if isempty(varargin)
            y = x(:,2);
            z = x(:,3);
            x = x(:,1);
        else
            y = varargin{1};
            z = varargin{2};
        end
        
        % compute position wrt to the grid vertices
        deltaX = this.gridSpacing(1);
        deltaY = this.gridSpacing(2);
        deltaZ = this.gridSpacing(3);
        xg = (x - this.gridOrigin(1)) / deltaX + 1;
        yg = (y - this.gridOrigin(2)) / deltaY + 1;
        zg = (z - this.gridOrigin(2)) / deltaZ + 1;
        
        % compute indices of values within interpolation area
        isInsideX = xg >= 2 & xg < this.gridSize(1)-1;
        isInsideY = yg >= 2 & yg < this.gridSize(2)-1;
        isInsideZ = zg >= 2 & zg < this.gridSize(3)-1;
        isInside = isInsideX & isInsideY & isInsideZ;
        inds = find(isInside);
        
        % keep only valid positions
        xg = xg(isInside);
        yg = yg(isInside);
        zg = zg(isInside);
        
        % initialize zeros translation vector
        nValid = length(xg);

        % pre-allocate result array
        nd = length(this.gridSize);
        np = length(this.params);
        jac = zeros(nd, np, length(x));

        % if all points are outside, return zeros matrix
        if sum(isInside) == 0
            return;
        end
        
        % coordinates within the unit tile
        xu = reshape(xg - floor(xg), [1 1 nValid]);
        yu = reshape(yg - floor(yg), [1 1 nValid]);       
        zu = reshape(zg - floor(zg), [1 1 nValid]);       
        
        dimGrid = this.gridSize;
        dimX    = dimGrid(1);
        dimXY   = dimX * dimGrid(2);
        dimXYZ  = dimXY * dimGrid(3);
        
        baseFuns = {...
            @BSplines.beta3_0, ...
            @BSplines.beta3_1, ...
            @BSplines.beta3_2, ...
            @BSplines.beta3_3};
        
        
        % pre-compute values of b-splines functions
        evals_i = zeros(nValid, 4);
        evals_j = zeros(nValid, 4);
        evals_k = zeros(nValid, 4);
        for i = 1:4
            fun = baseFuns{i};
            evals_i(:,i) = fun(xu);
            evals_j(:,i) = fun(yu);
            evals_k(:,i) = fun(zu);
        end
        
        % iteration on each tile of the grid
        for i = -1:2
            xv = floor(xg) + i;
            
            for j = -1:2
                yv = floor(yg) + j;
                
                % pre-compute weight for all vertices in same plane
                evals_ij = evals_i(:, i+2) .* evals_j(:, j+2);
                
                for k = -1:2
                    zv = floor(zg) + k;
                    
                    % linear index of translation components
                    indX = (zv - 1) * dimXY + (yv - 1) * dimX + xv;
                    indY = indX + dimXYZ;
                    indZ = indX + 2 * dimXYZ;
                                
                    % compute bezier weight of current vertex
                    b = evals_ij .* evals_k(:, k+2);
                
                    % update jacobian matrix (of size nd * np * nPts)
                    jacInds = (indX - 1 + (inds - 1) * np) * 3 + 1;
                    jac(jacInds) = b;
                    jacInds = (indY - 1 + (inds - 1) * np) * 3 + 1;
                    jac(jacInds + 1) = b;
                    jacInds = (indZ - 1 + (inds - 1) * np) * 3 + 1;
                    jac(jacInds + 1) = b;
                end
            end
        end
    end
   
end % general methods

%% I/O Methods
methods
    function writeToFile(this, file)
        % Write transform parameter to the given file handle
        % Assumes file handle is an instance of FileWriter.
        %
        % Example
        %   F = fopen('transfo.txt', 'wt');
        %   fprintf(F, '#--- Transform Parameters ---');
        %   writeToFile(TRANSFO, F);
        %   fclose(F);
        %
        
        closeFile = false;
        if ischar(file)
            file = fopen(file, 'wt');
            closeFile = true;
        end
        
        nDims = 3;
        
        fprintf(file, 'TransformType = %s\n', class(this));
        fprintf(file, 'TransformDimension = %d\n', nDims);
        
        nParams = length(this.params);
        fprintf(file, 'TransformParameterNumber = %d \n', nParams);
        
        pattern = ['TransformParameters =', repmat(' %g', 1, nParams) '\n'];
        fprintf(file, pattern, this.params);
        
        % some transform specific settings
        pattern = ['%s =' repmat(' %g', 1, nDims) '\n'];
        fprintf(file, pattern, 'TransformGridSize',     this.gridSize);
        fprintf(file, pattern, 'TransformGridOrigin',   this.gridOrigin);
        fprintf(file, pattern, 'TransformGridSpacing',  this.gridSpacing);

        % close file
        if closeFile
            fclose(file);
        end
    end
end

methods (Static)
    function transfo = readFromFile(fileName)
        % Read transform from the given file name.
        % Returns a new instance of CubicBSplineTransform3D.
        %
        % Example
        %   TRANSFO = CubicBSplineTransform3D.readFromFile('transfo.txt');
        
        map = readPropertyFile(fileName);
        transfo = CubicBSplineTransform3D.createFromPropertyMap(map);
    end
    
    function transfo = createFromPropertyMap(map)
        % Create a new transform from a set of properties
        
        grSize  = map('TransformGridSize');
        grSize  = cellfun(@str2double, regexp(grSize, '\s*', 'split'));
        grSpac  = map('TransformGridSpacing');
        grSpac  = cellfun(@str2double, regexp(grSpac, '\s*', 'split'));
        grOrig  = map('TransformGridOrigin');
        grOrig  = cellfun(@str2double, regexp(grOrig, '\s*', 'split'));
        
        transfo = CubicBSplineTransform3D(grSize, grSpac, grOrig);
        
        
        nbParams = str2double(map('TransformParameterNumber'));
        
        trParams = map('TransformParameters');
        trParams= cellfun(@str2double, regexp(trParams, '\s*', 'split'));
        
        if nbParams ~= length(trParams)
            error('Wrong number of parameters');
        end
        
        setParameters(transfo, trParams);
        
    end
end

end % classdef
