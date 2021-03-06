function tests = createTests()
%1
tests(1).dir='./g2-txt';
tests(1).filename='g2-2-10.txt';
tests(1).delimiter=' ';
tests(1).dimension=2;
tests(1).NClusters=2;
tests(1).distType=DISTTYPE.euclidean;
tests(1).minPts=int32([3,5,8,14,25]);
tests(1).eps=[2,2.4,3,4,4.8];
tests(1).eps2=[2.2,3,4.2,4.9,5.1];
tests(1).linePars=[0.006,1.8,0.013,1.5];
%2
tests(2).dir='./g2-txt';
tests(2).filename='g2-2-40.txt';
tests(2).delimiter=' ';
tests(2).dimension=2;
tests(2).NClusters=2;
tests(2).distType=DISTTYPE.euclidean;
tests(2).minPts=int32([3,5,8,14,25]);
tests(2).eps=[5,6,7,9,13];
tests(2).eps2=[8,9.5,11.5,14,17];
tests(2).linePars=[0.007,1.8,0.04,1.5];
%3
tests(3).dir='./t1';
tests(3).filename='Aggregation.txt';
tests(3).delimiter='\t';
tests(3).dimension=2;
tests(3).NClusters=7;
tests(3).distType=DISTTYPE.euclidean;
tests(3).minPts=int32([3,5,8,14,25]);
tests(3).eps=[0.9,1.1,1.5,1.9,2.8];
tests(3).eps2=[1.1,1.8,2.1,3.1,3.9];
tests(3).linePars=[0.025,-0.2,0.4,0.9];
%4
tests(4).dir='./t1';
tests(4).filename='Compound.txt';
tests(4).delimiter='\t';
tests(4).dimension=2;
tests(4).NClusters=5;
tests(4).distType=DISTTYPE.euclidean;
tests(4).minPts=int32([3,5,8,14,25]);
tests(4).eps=[0.8,0.9,1.4,2,2.8];
tests(4).eps2=[1.4,2,2.5,3,3.5];
tests(4).linePars=[0.01,0.4,0.04,0.2];
%5
tests(5).dir='./t1';
tests(5).filename='flame.txt';
tests(5).delimiter='\t';
tests(5).dimension=2;
tests(5).NClusters=2;
tests(5).distType=DISTTYPE.euclidean;
tests(5).minPts=int32([3,5,8,14,25]);
tests(5).eps=[0.8,0.9,1.2,1.9,2.7];
tests(5).eps2=[1.1,1.6,1.9,2.3,3.2];
tests(5).linePars=[0.1,0.4,0.4,0.4];
%6
tests(6).dir='./t1';
tests(6).filename='jain.txt';
tests(6).delimiter='\t';
tests(6).dimension=2;
tests(6).NClusters=2;
tests(6).distType=DISTTYPE.euclidean;
tests(6).minPts=int32([3,5,8,14,25]);
tests(6).eps=[0.8,0.9,1.4,1.8,2.3];
tests(6).eps2=[1.6,2,2.4,2.9,3.8];
tests(6).linePars=[0.01,0.4,0.04,0.4];
%7
tests(7).dir='./t1';
tests(7).filename='spiral.txt';
tests(7).delimiter='\t';
tests(7).dimension=2;
tests(7).NClusters=3;
tests(7).distType=DISTTYPE.euclidean;
tests(7).minPts=int32([3,5,8,14,25]);
tests(7).eps=[0.9,1.8,3,3.8,4.4];
tests(7).eps2=[1.7,2.7,3.6,4.4,5.9];
tests(7).linePars=[0.035,0.1,0.18,0.4];
%8
tests(8).dir='./t1';
tests(8).filename='t4.8k.txt';
tests(8).delimiter=' ';
tests(8).dimension=2;
tests(8).NClusters=6;
tests(8).distType=DISTTYPE.euclidean;
tests(8).minPts=int32([3,5,8,14,25]);
tests(8).eps=[3.4,4.2,5.2,6.4,8.2];
tests(8).eps2=[4.2,4.6,6.8,8.4,11];
tests(8).linePars=[0.001,1.8,0.005,0.9];
%9
tests(9).dir='./t1';
tests(9).filename='D31.txt';
tests(9).delimiter='\t';
tests(9).dimension=2;
tests(9).NClusters=31;
tests(9).distType=DISTTYPE.euclidean;
tests(9).minPts=int32([3,5,8,14,25]);
tests(9).eps=[0.35,0.45,0.5,0.6,0.85];
tests(9).eps2=[0.6,0.75,0.85,1,1.2];
tests(9).linePars=[0.001,-0.1,0.004,0.1];
%10
tests(10).dir='./t1';
tests(10).filename='pathbased.txt';
tests(10).delimiter='\t';
tests(10).dimension=2;
tests(10).NClusters=3;
tests(10).distType=DISTTYPE.euclidean;
tests(10).minPts=int32([3,5,8,14,25]);
tests(10).eps=[1.5,2.1,2.8,4,5.2];
tests(10).eps2=[1.8,2.2,3.0,5.1,8.2];
tests(10).linePars=[0.05,0.9,0.4,0.4];
%11
tests(11).dir='./t1';
tests(11).filename='cure-t2-4k.txt';
tests(11).delimiter=',';
tests(11).dimension=2;
tests(11).NClusters=5;
tests(11).distType=DISTTYPE.euclidean;
tests(11).minPts=int32([3,5,8,14,25]);
tests(11).eps=[0.04,0.055,0.07,0.08,0.1];
tests(11).eps2=[0.08,0.1,0.11,0.15,0.17];
tests(11).linePars=[0.0002,0.04,0.001,0.05];
end

