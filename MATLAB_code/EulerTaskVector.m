function r = EulerTaskVector(q1,q2,q3,q4,q5,q6,q7)
      r = [(79*cos(q1)*sin(q2))/250 - (33*sin(q1)*sin(q3))/400 - (107*cos(q6)*(sin(q4)*(sin(q1)*sin(q3) - cos(q1)*cos(q2)*cos(q3)) + cos(q1)*cos(q4)*sin(q2)))/1000 + (11*sin(q6)*(sin(q4)*(sin(q1)*sin(q3) - cos(q1)*cos(q2)*cos(q3)) + cos(q1)*cos(q4)*sin(q2)))/125 - (11*cos(q6)*(cos(q5)*(cos(q4)*(sin(q1)*sin(q3) - cos(q1)*cos(q2)*cos(q3)) - cos(q1)*sin(q2)*sin(q4)) + sin(q5)*(cos(q3)*sin(q1) + cos(q1)*cos(q2)*sin(q3))))/125 - (107*sin(q6)*(cos(q5)*(cos(q4)*(sin(q1)*sin(q3) - cos(q1)*cos(q2)*cos(q3)) - cos(q1)*sin(q2)*sin(q4)) + sin(q5)*(cos(q3)*sin(q1) + cos(q1)*cos(q2)*sin(q3))))/1000 + (33*cos(q4)*(sin(q1)*sin(q3) - cos(q1)*cos(q2)*cos(q3)))/400 + (48*sin(q4)*(sin(q1)*sin(q3) - cos(q1)*cos(q2)*cos(q3)))/125 + (33*cos(q1)*cos(q2)*cos(q3))/400 + (48*cos(q1)*cos(q4)*sin(q2))/125 - (33*cos(q1)*sin(q2)*sin(q4))/400;
           (33*cos(q1)*sin(q3))/400 + (79*sin(q1)*sin(q2))/250 + (107*cos(q6)*(sin(q4)*(cos(q1)*sin(q3) + cos(q2)*cos(q3)*sin(q1)) - cos(q4)*sin(q1)*sin(q2)))/1000 - (11*sin(q6)*(sin(q4)*(cos(q1)*sin(q3) + cos(q2)*cos(q3)*sin(q1)) - cos(q4)*sin(q1)*sin(q2)))/125 + (11*cos(q6)*(cos(q5)*(cos(q4)*(cos(q1)*sin(q3) + cos(q2)*cos(q3)*sin(q1)) + sin(q1)*sin(q2)*sin(q4)) + sin(q5)*(cos(q1)*cos(q3) - cos(q2)*sin(q1)*sin(q3))))/125 + (107*sin(q6)*(cos(q5)*(cos(q4)*(cos(q1)*sin(q3) + cos(q2)*cos(q3)*sin(q1)) + sin(q1)*sin(q2)*sin(q4)) + sin(q5)*(cos(q1)*cos(q3) - cos(q2)*sin(q1)*sin(q3))))/1000 - (33*cos(q4)*(cos(q1)*sin(q3) + cos(q2)*cos(q3)*sin(q1)))/400 - (48*sin(q4)*(cos(q1)*sin(q3) + cos(q2)*cos(q3)*sin(q1)))/125 - (33*sin(q1)*sin(q2)*sin(q4))/400 + (33*cos(q2)*cos(q3)*sin(q1))/400 + (48*cos(q4)*sin(q1)*sin(q2))/125;
           (79*cos(q2))/250 + (48*cos(q2)*cos(q4))/125 - (33*cos(q3)*sin(q2))/400 - (33*cos(q2)*sin(q4))/400 + (11*cos(q6)*(cos(q5)*(cos(q2)*sin(q4) - cos(q3)*cos(q4)*sin(q2)) + sin(q2)*sin(q3)*sin(q5)))/125 + (107*sin(q6)*(cos(q5)*(cos(q2)*sin(q4) - cos(q3)*cos(q4)*sin(q2)) + sin(q2)*sin(q3)*sin(q5)))/1000 - (107*cos(q6)*(cos(q2)*cos(q4) + cos(q3)*sin(q2)*sin(q4)))/1000 + (11*sin(q6)*(cos(q2)*cos(q4) + cos(q3)*sin(q2)*sin(q4)))/125 + (33*cos(q3)*cos(q4)*sin(q2))/400 + (48*cos(q3)*sin(q2)*sin(q4))/125 + 333/1000;
           atan2(((cos(q6)*(sin(q4)*(sin(q1)*sin(q3) - cos(q1)*cos(q2)*cos(q3)) + cos(q1)*cos(q4)*sin(q2)) + sin(q6)*(cos(q5)*(cos(q4)*(sin(q1)*sin(q3) - cos(q1)*cos(q2)*cos(q3)) - cos(q1)*sin(q2)*sin(q4)) + sin(q5)*(cos(q3)*sin(q1) + cos(q1)*cos(q2)*sin(q3))))^2 + (cos(q6)*(sin(q4)*(cos(q1)*sin(q3) + cos(q2)*cos(q3)*sin(q1)) - cos(q4)*sin(q1)*sin(q2)) + sin(q6)*(cos(q5)*(cos(q4)*(cos(q1)*sin(q3) + cos(q2)*cos(q3)*sin(q1)) + sin(q1)*sin(q2)*sin(q4)) + sin(q5)*(cos(q1)*cos(q3) - cos(q2)*sin(q1)*sin(q3))))^2)^(1/2), sin(q6)*(cos(q5)*(cos(q2)*sin(q4) - cos(q3)*cos(q4)*sin(q2)) + sin(q2)*sin(q3)*sin(q5)) - cos(q6)*(cos(q2)*cos(q4) + cos(q3)*sin(q2)*sin(q4)));
           0.316*cos(q2) - 0.0825*cos(q3)*sin(q2) + 0.333;
           atan2(cos(q6)*(sin(q4)*(cos(q1)*sin(q3) + cos(q2)*cos(q3)*sin(q1)) - cos(q4)*sin(q1)*sin(q2)) + sin(q6)*(cos(q5)*(cos(q4)*(cos(q1)*sin(q3) + cos(q2)*cos(q3)*sin(q1)) + sin(q1)*sin(q2)*sin(q4)) + sin(q5)*(cos(q1)*cos(q3) - cos(q2)*sin(q1)*sin(q3))), - cos(q6)*(sin(q4)*(sin(q1)*sin(q3) - cos(q1)*cos(q2)*cos(q3)) + cos(q1)*cos(q4)*sin(q2)) - sin(q6)*(cos(q5)*(cos(q4)*(sin(q1)*sin(q3) - cos(q1)*cos(q2)*cos(q3)) - cos(q1)*sin(q2)*sin(q4)) + sin(q5)*(cos(q3)*sin(q1) + cos(q1)*cos(q2)*sin(q3))))
           ];

end