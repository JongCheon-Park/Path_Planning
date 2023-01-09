function [Map_inform, Map] = calculate(Position, Goal, Map_x, Map_y, Parent, Map, Map_inform)

    dirX = [-1, 0, 1, 0, -1, 1, 1, -1];
    dirY = [0, -1, 0, 1, -1, -1, 1, 1,];
    able = [1, 1, 1, 1, 1, 1, 1, 1];
    cost = [10, 10, 10, 10, 14, 14, 14, 14];
    My_inform.Position = [Position(1), Position(2)];
    My_inform.g = cost;
    My_inform.able = able;
    My_inform.Parent = Parent;
    plan_x = My_inform.Position(1) + dirX;
    plan_y = My_inform.Position(2) + dirY;
    My_inform.h = abs(Goal(1) - plan_x)*10 + abs(Goal(2) - plan_y)*10;
    My_inform.f = My_inform.h + My_inform.g;

    % 맵을 벗어나는지 체크
    Non_able = find(plan_x <= 0 | plan_y <= 0 | plan_x > Map_x | plan_y > Map_y);
    My_inform.able(Non_able) = 0;
    My_inform.f(Non_able) = 0;

    % 장애물이 있는지 없는지 체크
    Non_able = find(plan_x > 0 & plan_y > 0 & plan_x <= Map_x & plan_y <= Map_y);
    for i = Non_able
        if Map(plan_x(i), plan_y(i), 3) == 100 % 장애물이 있는경우
            My_inform.able(i) = 0;
            My_inform.f(i) = 0;
        end
    end
    Map_inform{Position(1), Position(2)} = My_inform;
end