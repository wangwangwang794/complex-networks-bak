function edge = disassortative_mixing(edge, n_step, connectivity_func)
%DISASSORTATIVE_MIXING make the degree of connected nodes more dissimilar 
%by rewiring the edge. The degree sequence and connectivity preserved.
%
%Note:
% Only for undirected and unweighted graph.
%
%Syntax: 
% edge = DISASSORTATIVE_MIXING(edge, n_step)
%
%   edge: (matrix) The edge list of the graph defined by the adjacent
%         matrix. Each line is expressed as [src dst weight] where 'src',
%         'dst', 'weight' stand for the start, end nodes, weight of an 
%         edge respectively. The start point is zero. 
%
% connectivity_func: function handle for connectivity checking.
%
% n_step: number of rewiring steps.
%
%   edge:
%
%Example:
%
%Ref:
%
%Other m-file required: degree_sequence.m, check_idcontinuous4edge.m
%                       connectivity.m
%Subfunctions: None
%MAT-file required: None
%
%See also: assortative_mixing

% Author: x.s.
%  Email: followyourheart1211@gmail.com
%WebSite: http://followyourheart.github.io/
%History: July 31 15:25 2012 created

%--------------------------------------------------------------------------
if nargin < 3
    connectivity_func = @connectivity;
end

if size(edge, 2) < 2
    error('The edge must contain 2 columns at least');
end

edge = check_idcontinuous4edge(edge, 0);    %node id in edge start at 0
edge = edge(:, 1:2);

m_edge = length(edge);

degree = degree_sequence(edge, 0);   %1-id(start at 0), 2-degree

new_edge = edge;

k = 1;
fprintf('MIXING: 0%%');
for i = 1 : n_step
    if i == n_step * k / 10
        fprintf('==>%2d%%', k*10);
        k = k + 1;
    end
    
    %1. choose two edges at random
    id_s    = randperm(m_edge, 2);
    edges_s = edge(id_s, :);
    
    nodes_s = unique(edges_s(:));
    
    if length(nodes_s) ~= 4
        continue;
    end
    
    %2. order the four nodes with respect to their degrees
    deg_s = degree(ismember(degree(:,1), nodes_s), :);
    deg_s = sortrows(deg_s, 2);
    
    if length(unique(deg_s(:, 2))) == 1
        continue;
    end

    %3. rewire & check exist
    id4 = deg_s(4, 1);
    id3 = deg_s(3, 1);
    id2 = deg_s(2, 1);
    id1 = deg_s(1, 1);
    exist41 = sum(edge(:, 1) == id4 & edge(:, 2) == id1);
    exist14 = sum(edge(:, 1) == id1 & edge(:, 2) == id4);
    exist23 = sum(edge(:, 1) == id2 & edge(:, 2) == id3);
    exist32 = sum(edge(:, 1) == id3 & edge(:, 2) == id2);
    
    if(exist41 + exist14 + exist23 + exist32 ~= 0)
        continue;
    end
    
    %4. new edges
    edges_n_1 = [id4, id1];
    edges_n_2 = [id3, id2];
    
    new_edge(id_s, :) = [edges_n_1; edges_n_2];  
    
    %5. check connectivity
    conn = connectivity_func(new_edge, 0);
    
    %6. discard
    if conn == 0
        new_edge = edge;
        
        continue;
    end
    
    edge  = new_edge;
end
fprintf('\n');

edge = check_idcontinuous4edge(edge, 0);
%--------------------------------------------------------------------------
end