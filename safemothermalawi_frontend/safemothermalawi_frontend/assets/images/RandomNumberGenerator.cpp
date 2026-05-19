#include <iostream>
#include <cstdlib>
#include <ctime>

using namespace std;
int main(){
    //seed the random number generator
    srand(time(0));
    //generate a random number between 0 and 11
    int daysUntilExpiration = rand % 12;
cout << Days untill expiration: " << daysUntilExpiration << endl;

// check conditions 
if (daysUtillExpirtaion == 0){
cout << "Your subscription has expired." << endl;
}
else if
(daysUntilExpiration ==1){
cout << "your subscription expires within a day!" <<endl;
cout <<"Renew now and save 20%"<<end1;
}
else if (daysUntilEXpiration <=5){
cout<<"ypur subscription expires in" << daysUntilExpiration << "days."<<endl;
cout "Renew now and save 10%!" <<endl;
}
else{
cout <<"You have an active subscription." <<endl;
}
return 0;

}