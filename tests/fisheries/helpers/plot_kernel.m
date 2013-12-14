vk_project = load('kernel.mat');

V = vk_project.V;
K = convhull(V(:,1), V(:,2));
pts = V(K,:);

plot(pts(:,1), pts(:,2), 'g--', 'LineWidth', 4);
