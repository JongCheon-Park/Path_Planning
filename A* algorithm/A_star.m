clc
clear all
close all


%% 맵 세팅
Map_x = 10;
Map_y = 10;
Start = [1,1];
Parent = Start;
Goal = [10, 10];

Map = zeros(Map_x, Map_y, 3);
Map(Start(1),Start(2), [1,3]) = 100; % Start Point
Map(Goal(1),Goal(2),[1,2]) = 100; % End Point

Map(:,:,3) = [100     0     100     0     0    100     0     0     0     0;
    0     0     0     100     0     100     0     0     0     0;
    0     100     0     100     0     100     0     0     0     0;
    0     100     0     100     0     0     100     100     0     0;
    0     100     0     100     100     0     0     100     100     100;
    0     0     0     0     0     0    0     0     0     100;
    100     0     100     0     0     0     100     0     0     0;
    100     0     0     0     100     0     100     100     0     0;
    0     100     100     0     100     0     100     100     0     0;
    0     0     0     0     0     100     0     100     0     0];

Image_Map(:,:,1) = Map(:,:,1);
Image_Map(:,:,2) = Map(:,:,2);
Image_Map(:,:,3) = Map(:,:,3);

dirX = [-1, 0, 1, 0, -1, 1, 1, -1];
dirY = [0, -1, 0, 1, -1, -1, 1, 1,];
% able = [1, 1, 1, 1, 1, 1, 1, 1];
% cost = [10, 10, 10, 10, 14, 14, 14, 14];
Open_Position = [Start(1),Start(2),Start(1),Start(2),NaN];
Closed_Position = [Start(1),Start(2),Start(1),Start(2), NaN];

My_x = Start(1);
My_y = Start(2);
Map_inform =[];
filename = 'test.gif';


%% 길찾기
for i = 1 : 50
    % 현재 위치 My_x, My_y 에서 갈 수 있는 곳을 계산
    [Map_inform, Map] = calculate([My_x, My_y], Goal, Map_x, Map_y, Parent, Map, Map_inform);

    if max(Map_inform{My_x, My_y}.able) == 0
        Map(My_x, My_y, 3) = 100;
        disp('No way')
        My_x = Open_Position(end,1);
        My_y = Open_Position(end,2);
        Parent = Open_Position(end,3:4);
        cost = abs(My_x - Goal(1)) * 10 + abs(My_y - Goal(2)) * 10;
        Open_Position(end,:) = [];
        Map(My_x, My_y, 2:3) = 100;
        [Map_inform, Map] = calculate([My_x, My_y], Goal, Map_x, Map_y, Parent, Map, Map_inform);
    end

    action = find(Map_inform{My_x, My_y}.f == min(Map_inform{My_x, My_y}.f(find(Map_inform{My_x, My_y}.able == 1))));
    Can_Do_action = find(Map_inform{My_x, My_y}.able == 1);
    Can_Go_x = My_x + dirX(Can_Do_action);
    Can_Go_y = My_y + dirY(Can_Do_action);



    Parent = [My_x, My_y];
    for number = 1 : size(Can_Go_x', 1)
        if isempty(find(Open_Position(:,1) == Can_Go_x(number) & Open_Position(:,2) == Can_Go_y(number)))
            cost = abs(Can_Go_x(number) - Goal(1)) * 10 + abs(Can_Go_x(number) - Goal(2)) * 10;
            Open_Position = [Open_Position; Can_Go_x(number), Can_Go_y(number), Parent, cost];
            Map(Can_Go_x(number), Can_Go_y(number), [1:2]) = 0.3;
        end
    end
    My_x = My_x + dirX(action(1));
    My_y = My_y + dirY(action(1));
    [index_x, index_Y] = find(Open_Position(:,1)==My_x & Open_Position(:,2) == My_y);
    if ~isempty(index_x)
        Parent = Open_Position(index_x,3:4);
        My_x = Open_Position(index_x,1);
        My_y = Open_Position(index_x,2);

    end

    Remove_Open_position = find(Open_Position(:,1) == My_x & Open_Position(:,2) == My_y);
    Open_Position(Remove_Open_position, :) = [];
    %방문하는 경우 장애물로 처리됨
    Map(My_x, My_y, [2, 3]) = 0;
    Map(My_x, My_y, 1) = 100;
    image(Map)
    set(gca,'Ydir','normal')
    Map(My_x, My_y, 1) = 0;
    Map(My_x, My_y, [2, 3]) = 100;

    frame = getframe(1);
    img = frame2im(frame);
    [imind cm] = rgb2ind(img,256);
    if i == 1
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,filename,'gif','DelayTime', 0.1, 'WriteMode','append');
    end


    if My_x == Goal(1) & My_y == Goal(2)
        %         figure(2)
        disp('Arrive!!!');
        [Map_inform, Map] = calculate([My_x, My_y], Goal, Map_x, Map_y, Parent, Map, Map_inform);
        p_x = Map_inform{My_x, My_y}.Parent(1);
        p_y = Map_inform{My_x, My_y}.Parent(2);
        %         subplot(1,2,1)
        %         imshow(Map)
        %         set(gca,'Ydir','normal')
        Map(:,:,[1:3]) = 0;
        while p_x ~= 1 | p_y ~= 1
            Map(p_x, p_y, [2, 3]) = 100;
            Pr = Map_inform{p_x, p_y}.Parent;
            p_x = Pr(1);
            p_y = Pr(2);
        end
        disp('End')
        Map(Start(1), Start(2), 1) = 100;
        Map(Goal(1), Goal(2), [1,2]) = 100;
        %         subplot(1,2,2)



        Map(:,:,3) = Image_Map(:,:,3);

        image(Map);
        set(gca,'Ydir','normal')

        frame = getframe(1);
        img = frame2im(frame);
        [imind cm] = rgb2ind(img,256);
        for i = 1 : 10
            imwrite(imind,cm,filename,'gif','DelayTime', 0.1, 'WriteMode','append');
        end
        break
    end
end