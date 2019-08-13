classdef NelderMeadSimplexOptimizer < Optimizer
% Simplex optimizer adapted from book "Numerical Recipes 3".
%
%   OPT = NelderMeadSimplexOptimizer()
%
%   Example
%     % Run the simplex optimizer on the Rosenbrock function
%     optimizer = NelderMeadSimplexOptimizer(@rosenbrock, [0 0], [.01 .01]);
%     [xOpt value] = optimizer.startOptimization();
%     xOpt
%       xOpt =
%           0.9993    0.9984
%     value
%       value =
%           5.5924e-006
%
%   See also
%     Optimizer, MatlabSimplexOptimizer
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2011-01-09,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

%% Properties
properties
    % maximum number of iterations
    nIter = 200;
    
    % tolerance on function value 
    ftol = 1e-5;
    
    % delta in each direction
    deltas; 
    
    % the inner simplex, as a (ND+1)-by-ND array
    simplex;
    
    % the vector of function evaluations
    evals;
    
    % the sum of the vertex coordinates
    psum;
    
    % number of function evaluation
    numFunEvals;
end

%% Constructor
methods
    function this = NelderMeadSimplexOptimizer(varargin)
        %Create a new Simplex Optimizer
        %
        % OPT = NelderMeadSimplexOptimizer();
        % Creates a new optimizer, whose inner fields will be initialized
        % later.
        %
        % OPT = NelderMeadSimplexOptimizer(FUN, PARAMS0);
        % OPT = NelderMeadSimplexOptimizer(FUN, PARAMS0, DELTA);
        % FUN is either a function handle, or an instance of CostFunction
        % PARAMS0 is the initial set of parameters
        % DELTA is the variation of parameters in each direction, given
        % either as a scalar, or as a row vector with the same size as the
        % parameter vector. If not specified, it is initialized as a row
        % vector the same size as PARAMS0, with values 1e-5.
        %
        
        this = this@Optimizer();
        
        if nargin==0
            return;
        end
        
        if nargin >= 2
            % setup cost function
            this.setCostFunction(varargin{1});

            % setup initial optimal value
            params = varargin{2};
            this.setInitialParameters(params);
            this.setParameters(params);

        end

        % setup vector of variation amounts in each direction
        if nargin > 2
            del = varargin{3};
        else
            del = 1e-5;
        end
        
        if length(del) == 1
            this.deltas = del * ones(size(params));
        else
            this.deltas = del;
        end
        
    end % end of constructor
end

%% Private functions
methods (Access = private)
    function initializeSimplex(this)
        % Initialize the simplex. 
        % This is a (ND+1)-by-ND array containing the coordinates of a
        % vertex on each row.
        
        if isempty(this.params)
            if isempty(this.initialParameters)
                error('oolip:NelderMeadSimplexOptimizer:initialization', ...
                    'Need to specify initial parameters');
            end
            this.params = this.initialParameters;
        end
        
        nd = length(this.params);
        
        % ensure delta has valid value
        if isempty(this.deltas)
            this.deltas = 1e-5 * ones(1, nd);
        end
        
        % initialize vertex coordinates
        this.simplex = repmat(this.params, nd+1, 1);
        for i=1:nd
            this.simplex(i+1, i) = this.params(i) + this.deltas(i);
        end
        
        % compute sum of vertex coordinates
        this.psum = sum(this.simplex, 1);

        % evaluate function for each vertex of the simplex
        this.evals = zeros(nd+1, 1);
        for i=1:nd+1
            this.evals(i) = this.costFunction(this.simplex(i, :));
        end
        
        this.numFunEvals = 0;

   end
    
    function [ptry, ytry] = evaluateReflection(this, ihi, fac)
        % helper function that evaluates the value of the function at the
        % reflection of point with index ihi
        %
        % [PTRY YTRY] = evaluateReflection(PT_INDEX, FACTOR)
        % PT_INDEX index of the vertex that is updated
        % FACTOR expansion (>1), reflection (<0) or contraction (0<F<1)
        %   factor 
        % PTRY is the new computed point
        % YTRY is the function evaluation at the newly evaluated point
        
        % compute weighting factors
        nd = length(this.params);
        fac1 = (1 - fac) / nd;
        fac2 = fac1 - fac;
         
        % position of the new candidate point
        ptry = this.psum * fac1 - this.simplex(ihi, :) * fac2;
        
        % evaluate function value
        ytry = this.costFunction(ptry);
        this.numFunEvals = this.numFunEvals + 1;

    end

    function updateSimplex(this, ihi, pTry, yTry)
        this.evals(ihi) = yTry;
        this.psum = this.psum - this.simplex(ihi, :) + pTry ;
        this.simplex(ihi, :) = pTry;
    end
    
    function contractSimplex(this, indLow)
        
        nd = length(this.params);
        
        pLow = this.simplex(indLow,:);
        for i = [1:indLow-1 indLow+1:nd]
            this.simplex(i, :) = (this.simplex(i,:) + pLow) * .5;
            this.evals(i) = this.costFunction(this.simplex(i,:));
        end
        
        this.numFunEvals = this.numFunEvals + nd;

    end
    
end % private methods

end % classdef